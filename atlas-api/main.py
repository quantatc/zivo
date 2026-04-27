"""
Atlas Operations demo API.

Single-file FastAPI service that owns all DB access for the Atlas demo.
Open WebUI tools and n8n workflows both call this so SQL lives in one place
and tools stay credential-free. Internal-only port; not exposed by Caddy.
"""

from __future__ import annotations

from contextlib import asynccontextmanager
from datetime import datetime, timedelta, timezone
import logging
from typing import Any, Literal

import asyncpg
import httpx
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


# ---------------------------------------------------------------------------
# Settings
# ---------------------------------------------------------------------------

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    postgres_host: str = "postgres"
    postgres_port: int = 5432
    postgres_db: str = "zivo"
    postgres_user: str = "zivo"
    postgres_password: str = ""

    litellm_base_url: str = "http://litellm:4000"
    litellm_api_key: str = ""
    litellm_email_model: str = "Zivo Fast (GPT-5 Mini)"

    n8n_webhook_base_url: str = "http://n8n:5678/webhook"
    atlas_demo_auto_refresh_dates: bool = True


settings = Settings()
logger = logging.getLogger("atlas-api")


async def _refresh_demo_dates_if_stale(pool: asyncpg.Pool) -> None:
    """
    Keep the Atlas demo timeline current when a persisted Postgres volume is
    reused across demo days.

    The seed data is generated relative to NOW(), but Docker init scripts only
    run for a fresh data directory. Without this, a week-old volume makes
    "last 7 days" KPI requests look empty even though the demo is seeded.
    """
    today = datetime.now(timezone.utc).date()

    async with pool.acquire() as con:
        async with con.transaction():
            await con.execute("SELECT pg_advisory_xact_lock(423019042)")

            max_snapshot = await con.fetchval("SELECT MAX(snapshot_date) FROM kpi_snapshots")
            if max_snapshot is None:
                return

            delta_days = (today - max_snapshot).days
            if delta_days <= 0:
                return

            await con.execute(
                """
                UPDATE transactions
                SET created_at = created_at + ($1::int * INTERVAL '1 day')
                """,
                delta_days,
            )
            await con.execute(
                """
                UPDATE investigation_cases
                SET opened_at = opened_at + ($1::int * INTERVAL '1 day'),
                    resolved_at = resolved_at + ($1::int * INTERVAL '1 day')
                """,
                delta_days,
            )

            # Move dates out of the way first to avoid primary-key collisions
            # on the contiguous kpi_snapshots.snapshot_date range.
            await con.execute("UPDATE kpi_snapshots SET snapshot_date = snapshot_date + 10000")
            await con.execute(
                """
                UPDATE kpi_snapshots
                SET snapshot_date = snapshot_date - 10000 + $1::int,
                    generated_at = generated_at + ($1::int * INTERVAL '1 day')
                """,
                delta_days,
            )

    logger.info("Refreshed Atlas demo dates by %s day(s)", delta_days)


# ---------------------------------------------------------------------------
# Lifespan: open / close the asyncpg pool
# ---------------------------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.pool = await asyncpg.create_pool(
        host=settings.postgres_host,
        port=settings.postgres_port,
        database=settings.postgres_db,
        user=settings.postgres_user,
        password=settings.postgres_password,
        min_size=1,
        max_size=8,
    )
    if settings.atlas_demo_auto_refresh_dates:
        await _refresh_demo_dates_if_stale(app.state.pool)
    app.state.http = httpx.AsyncClient(timeout=30.0)
    try:
        yield
    finally:
        await app.state.pool.close()
        await app.state.http.aclose()


app = FastAPI(title="Atlas API", version="0.1.0", lifespan=lifespan)


# ---------------------------------------------------------------------------
# Pydantic models
# ---------------------------------------------------------------------------

class Transaction(BaseModel):
    id: int
    amount: float
    category: str
    flagged: bool
    created_at: datetime
    vendor_id: int | None = None
    vendor_name: str | None = None
    customer_id: int | None = None
    customer_name: str | None = None
    description: str | None = None
    policy_violation: str | None = None
    reviewed_by: str | None = None
    review_note: str | None = None


class ReviewRequest(BaseModel):
    reviewer: str = Field(..., description="Name or email of the reviewer")
    note: str = Field(..., description="Reviewer notes")
    mark_resolved: bool = Field(False, description="If true, also clear the flagged bit")


class CaseCreateRequest(BaseModel):
    transaction_id: int
    notes: str
    opened_by: str = "system"


class Case(BaseModel):
    id: int
    transaction_id: int
    status: str
    opened_at: datetime
    resolved_at: datetime | None = None
    opened_by: str
    notes: str | None = None


class VendorSummary(BaseModel):
    id: int
    name: str
    category: str
    on_watchlist: bool
    total_spend: float
    transaction_count: int
    flagged_count: int
    last_transaction_at: datetime | None = None
    recent_flagged: list[Transaction] = Field(default_factory=list)


class KpiSnapshot(BaseModel):
    period: str
    range_start: datetime
    range_end: datetime
    revenue: float
    expenses: float
    flagged_count: int
    open_cases: int
    new_cases: int


class DraftEmailRequest(BaseModel):
    vendor_id: int
    topic: str = Field(..., description="What the email is about, e.g. 'late invoice 4471'")
    tone: Literal["polite", "firm", "friendly"] = "polite"


class DraftEmailResponse(BaseModel):
    vendor: str
    contact_email: str | None
    subject: str
    body: str


class TriggerWorkflowRequest(BaseModel):
    workflow_slug: str = Field(..., description="n8n webhook slug, e.g. 'fraud-policy-check'")
    payload: dict[str, Any] = Field(default_factory=dict)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _row_to_transaction(row: asyncpg.Record) -> Transaction:
    return Transaction(
        id=row["id"],
        amount=float(row["amount"]),
        category=row["category"],
        flagged=row["flagged"],
        created_at=row["created_at"],
        vendor_id=row.get("vendor_id"),
        vendor_name=row.get("vendor_name"),
        customer_id=row.get("customer_id"),
        customer_name=row.get("customer_name"),
        description=row.get("description"),
        policy_violation=row.get("policy_violation"),
        reviewed_by=row.get("reviewed_by"),
        review_note=row.get("review_note"),
    )


def _period_to_range(period: str) -> tuple[datetime, datetime]:
    now = datetime.now(timezone.utc)
    if period == "7d":
        return now - timedelta(days=7), now
    if period == "30d":
        return now - timedelta(days=30), now
    if period == "mtd":
        start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        return start, now
    raise HTTPException(status_code=400, detail=f"Unknown period: {period}")


# ---------------------------------------------------------------------------
# Health
# ---------------------------------------------------------------------------

@app.get("/healthz")
async def healthz() -> dict[str, str]:
    async with app.state.pool.acquire() as con:
        await con.fetchval("SELECT 1")
    return {"status": "ok"}


# ---------------------------------------------------------------------------
# Transactions
# ---------------------------------------------------------------------------

_TX_SELECT = """
    SELECT
        t.id, t.amount, t.category, t.flagged, t.created_at,
        t.vendor_id, v.name AS vendor_name,
        t.customer_id, c.name AS customer_name,
        t.description, t.policy_violation, t.reviewed_by, t.review_note
    FROM transactions t
    LEFT JOIN vendors v   ON v.id = t.vendor_id
    LEFT JOIN customers c ON c.id = t.customer_id
"""


@app.get("/transactions", response_model=list[Transaction])
async def list_transactions(
    from_date: datetime | None = Query(None, alias="from"),
    to_date: datetime | None = Query(None, alias="to"),
    flagged: bool | None = None,
    vendor_id: int | None = None,
    category: str | None = None,
    limit: int = Query(50, ge=1, le=500),
):
    where: list[str] = []
    params: list[Any] = []
    if from_date is not None:
        params.append(from_date)
        where.append(f"t.created_at >= ${len(params)}")
    if to_date is not None:
        params.append(to_date)
        where.append(f"t.created_at <= ${len(params)}")
    if flagged is not None:
        params.append(flagged)
        where.append(f"t.flagged = ${len(params)}")
    if vendor_id is not None:
        params.append(vendor_id)
        where.append(f"t.vendor_id = ${len(params)}")
    if category is not None:
        params.append(category)
        where.append(f"t.category = ${len(params)}")

    sql = _TX_SELECT
    if where:
        sql += " WHERE " + " AND ".join(where)
    params.append(limit)
    sql += f" ORDER BY t.created_at DESC LIMIT ${len(params)}"

    async with app.state.pool.acquire() as con:
        rows = await con.fetch(sql, *params)
    return [_row_to_transaction(r) for r in rows]


@app.get("/transactions/{tx_id}", response_model=Transaction)
async def get_transaction(tx_id: int):
    async with app.state.pool.acquire() as con:
        row = await con.fetchrow(_TX_SELECT + " WHERE t.id = $1", tx_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return _row_to_transaction(row)


@app.post("/transactions/{tx_id}/review", response_model=Transaction)
async def review_transaction(tx_id: int, body: ReviewRequest):
    async with app.state.pool.acquire() as con:
        async with con.transaction():
            updated = await con.fetchval(
                """
                UPDATE transactions
                SET reviewed_by = $1,
                    review_note = $2,
                    flagged = CASE WHEN $3 THEN FALSE ELSE flagged END
                WHERE id = $4
                RETURNING id
                """,
                body.reviewer, body.note, body.mark_resolved, tx_id,
            )
            if updated is None:
                raise HTTPException(status_code=404, detail="Transaction not found")
            row = await con.fetchrow(_TX_SELECT + " WHERE t.id = $1", tx_id)
    return _row_to_transaction(row)


class TransactionCreate(BaseModel):
    amount: float
    category: str
    vendor_id: int
    customer_id: int
    description: str | None = None
    flagged: bool = False
    policy_violation: str | None = None


class PolicyVerdict(BaseModel):
    flagged: bool
    policy_violation: str | None = None


@app.post("/transactions/{tx_id}/policy", response_model=Transaction)
async def apply_policy_verdict(tx_id: int, verdict: PolicyVerdict):
    """Used by the n8n fraud-policy-check workflow to write back an LLM verdict."""
    async with app.state.pool.acquire() as con:
        updated = await con.fetchval(
            """
            UPDATE transactions
            SET flagged = $1, policy_violation = $2
            WHERE id = $3
            RETURNING id
            """,
            verdict.flagged, verdict.policy_violation, tx_id,
        )
        if updated is None:
            raise HTTPException(status_code=404, detail="Transaction not found")
        row = await con.fetchrow(_TX_SELECT + " WHERE t.id = $1", tx_id)
    return _row_to_transaction(row)


@app.post("/transactions", response_model=Transaction, status_code=201)
async def create_transaction(body: TransactionCreate):
    async with app.state.pool.acquire() as con:
        new_id = await con.fetchval(
            """
            INSERT INTO transactions
                (amount, category, flagged, vendor_id, customer_id, description, policy_violation)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING id
            """,
            body.amount, body.category, body.flagged, body.vendor_id,
            body.customer_id, body.description, body.policy_violation,
        )
        row = await con.fetchrow(_TX_SELECT + " WHERE t.id = $1", new_id)
    return _row_to_transaction(row)


# ---------------------------------------------------------------------------
# Flagged shortcut
# ---------------------------------------------------------------------------

@app.get("/flagged", response_model=list[Transaction])
async def get_flagged(limit: int = Query(20, ge=1, le=200)):
    async with app.state.pool.acquire() as con:
        rows = await con.fetch(
            _TX_SELECT + " WHERE t.flagged = TRUE ORDER BY t.created_at DESC LIMIT $1",
            limit,
        )
    return [_row_to_transaction(r) for r in rows]


# ---------------------------------------------------------------------------
# Vendors
# ---------------------------------------------------------------------------

@app.get("/vendors")
async def list_vendors(search: str | None = None, limit: int = Query(50, ge=1, le=200)):
    if search:
        sql = "SELECT id, name, category, on_watchlist FROM vendors WHERE name ILIKE $1 ORDER BY name LIMIT $2"
        params: list[Any] = [f"%{search}%", limit]
    else:
        sql = "SELECT id, name, category, on_watchlist FROM vendors ORDER BY name LIMIT $1"
        params = [limit]
    async with app.state.pool.acquire() as con:
        rows = await con.fetch(sql, *params)
    return [dict(r) for r in rows]


@app.get("/vendors/{vendor_id}/summary", response_model=VendorSummary)
async def vendor_summary(vendor_id: int):
    async with app.state.pool.acquire() as con:
        vendor = await con.fetchrow(
            "SELECT id, name, category, on_watchlist FROM vendors WHERE id = $1",
            vendor_id,
        )
        if vendor is None:
            raise HTTPException(status_code=404, detail="Vendor not found")
        agg = await con.fetchrow(
            """
            SELECT
                COALESCE(SUM(amount), 0) AS total_spend,
                COUNT(*)                 AS transaction_count,
                SUM(CASE WHEN flagged THEN 1 ELSE 0 END) AS flagged_count,
                MAX(created_at)          AS last_transaction_at
            FROM transactions
            WHERE vendor_id = $1
            """,
            vendor_id,
        )
        recent = await con.fetch(
            _TX_SELECT
            + " WHERE t.vendor_id = $1 AND t.flagged = TRUE ORDER BY t.created_at DESC LIMIT 5",
            vendor_id,
        )
    return VendorSummary(
        id=vendor["id"],
        name=vendor["name"],
        category=vendor["category"],
        on_watchlist=vendor["on_watchlist"],
        total_spend=float(agg["total_spend"] or 0),
        transaction_count=agg["transaction_count"] or 0,
        flagged_count=agg["flagged_count"] or 0,
        last_transaction_at=agg["last_transaction_at"],
        recent_flagged=[_row_to_transaction(r) for r in recent],
    )


# ---------------------------------------------------------------------------
# KPI snapshot
# ---------------------------------------------------------------------------

@app.get("/kpi/snapshot", response_model=KpiSnapshot)
async def kpi_snapshot(period: Literal["7d", "30d", "mtd"] = "7d"):
    if settings.atlas_demo_auto_refresh_dates:
        await _refresh_demo_dates_if_stale(app.state.pool)
    start, end = _period_to_range(period)
    async with app.state.pool.acquire() as con:
        tx = await con.fetchrow(
            """
            SELECT
                COALESCE(SUM(amount), 0) AS expenses,
                SUM(CASE WHEN flagged THEN 1 ELSE 0 END) AS flagged_count
            FROM transactions
            WHERE created_at >= $1 AND created_at <= $2
            """,
            start, end,
        )
        rev = await con.fetchval(
            """
            SELECT COALESCE(SUM(revenue), 0)
            FROM kpi_snapshots
            WHERE snapshot_date BETWEEN $1::date AND $2::date
            """,
            start, end,
        )
        open_cases = await con.fetchval(
            "SELECT COUNT(*) FROM investigation_cases WHERE status IN ('open', 'under_review')"
        )
        new_cases = await con.fetchval(
            "SELECT COUNT(*) FROM investigation_cases WHERE opened_at >= $1 AND opened_at <= $2",
            start, end,
        )
    return KpiSnapshot(
        period=period,
        range_start=start,
        range_end=end,
        revenue=float(rev or 0),
        expenses=float(tx["expenses"] or 0),
        flagged_count=tx["flagged_count"] or 0,
        open_cases=open_cases or 0,
        new_cases=new_cases or 0,
    )


# ---------------------------------------------------------------------------
# Cases
# ---------------------------------------------------------------------------

@app.get("/cases", response_model=list[Case])
async def list_cases(
    status: Literal["open", "under_review", "resolved", "dismissed"] | None = None,
    limit: int = Query(50, ge=1, le=200),
):
    sql = "SELECT id, transaction_id, status, opened_at, resolved_at, opened_by, notes FROM investigation_cases"
    params: list[Any] = []
    if status is not None:
        params.append(status)
        sql += f" WHERE status = ${len(params)}"
    params.append(limit)
    sql += f" ORDER BY opened_at DESC LIMIT ${len(params)}"
    async with app.state.pool.acquire() as con:
        rows = await con.fetch(sql, *params)
    return [Case(**dict(r)) for r in rows]


@app.post("/cases", response_model=Case, status_code=201)
async def create_case(body: CaseCreateRequest):
    async with app.state.pool.acquire() as con:
        exists = await con.fetchval("SELECT 1 FROM transactions WHERE id = $1", body.transaction_id)
        if not exists:
            raise HTTPException(status_code=404, detail="Transaction not found")
        row = await con.fetchrow(
            """
            INSERT INTO investigation_cases (transaction_id, status, opened_by, notes)
            VALUES ($1, 'open', $2, $3)
            RETURNING id, transaction_id, status, opened_at, resolved_at, opened_by, notes
            """,
            body.transaction_id, body.opened_by, body.notes,
        )
    return Case(**dict(row))


# ---------------------------------------------------------------------------
# Actions: LLM-backed email draft + n8n workflow trigger
# ---------------------------------------------------------------------------

@app.post("/actions/draft-vendor-email", response_model=DraftEmailResponse)
async def draft_vendor_email(body: DraftEmailRequest):
    async with app.state.pool.acquire() as con:
        vendor = await con.fetchrow(
            "SELECT id, name, contact_email FROM vendors WHERE id = $1", body.vendor_id
        )
        if vendor is None:
            raise HTTPException(status_code=404, detail="Vendor not found")
        recent = await con.fetch(
            """
            SELECT id, amount, created_at, description
            FROM transactions
            WHERE vendor_id = $1
            ORDER BY created_at DESC
            LIMIT 5
            """,
            body.vendor_id,
        )

    context_lines = "\n".join(
        f"- TX#{r['id']} on {r['created_at'].date()}: ${float(r['amount']):,.2f} - {r['description'] or ''}"
        for r in recent
    ) or "(no recent transactions on file)"

    system = (
        "You draft short, professional vendor emails for an operations team at Atlas Operations, "
        "an 80-person services firm. Always return a JSON object with keys 'subject' and 'body'. "
        "Keep the body under 120 words. Sign as 'Maya Chen, Operations'."
    )
    user = (
        f"Vendor: {vendor['name']}\n"
        f"Tone: {body.tone}\n"
        f"Topic: {body.topic}\n\n"
        f"Recent transactions on file:\n{context_lines}\n\n"
        "Return JSON only."
    )

    try:
        resp = await app.state.http.post(
            f"{settings.litellm_base_url}/v1/chat/completions",
            headers={"Authorization": f"Bearer {settings.litellm_api_key}"},
            json={
                "model": settings.litellm_email_model,
                "messages": [
                    {"role": "system", "content": system},
                    {"role": "user", "content": user},
                ],
                "response_format": {"type": "json_object"},
                "temperature": 0.4,
            },
        )
        resp.raise_for_status()
        content = resp.json()["choices"][0]["message"]["content"]
        import json
        data = json.loads(content)
        subject = data.get("subject", f"Re: {body.topic}")
        body_text = data.get("body", "")
    except Exception as e:
        # Fallback so the demo never hard-fails if LiteLLM is misconfigured
        subject = f"Re: {body.topic}"
        body_text = (
            f"Hi {vendor['name']} team,\n\n"
            f"Following up on {body.topic}. Could you confirm next steps at your earliest convenience?\n\n"
            "Thanks,\nMaya Chen, Operations\n\n"
            f"[draft fallback - LLM unavailable: {e}]"
        )

    return DraftEmailResponse(
        vendor=vendor["name"],
        contact_email=vendor["contact_email"],
        subject=subject,
        body=body_text,
    )


@app.post("/actions/trigger-workflow")
async def trigger_workflow(body: TriggerWorkflowRequest) -> dict[str, Any]:
    url = f"{settings.n8n_webhook_base_url.rstrip('/')}/{body.workflow_slug}"
    try:
        resp = await app.state.http.post(url, json=body.payload)
        return {
            "status": "triggered",
            "workflow": body.workflow_slug,
            "http_status": resp.status_code,
            "response": resp.text[:500],
        }
    except httpx.HTTPError as e:
        raise HTTPException(status_code=502, detail=f"n8n call failed: {e}")
