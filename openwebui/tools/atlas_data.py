"""
title: Atlas Data
author: Zivo
author_url: https://zivo.tafarax.com
description: Read-only access to Atlas Operations transactions, vendors, KPIs, and cases via the atlas-api service.
required_open_webui_version: 0.4.0
requirements: httpx
version: 0.1.0
license: MIT
"""

from __future__ import annotations

import httpx
from pydantic import BaseModel, Field


class Tools:
    class Valves(BaseModel):
        atlas_api_url: str = Field(
            default="http://atlas-api:8000",
            description="Base URL of the atlas-api service (container-internal).",
        )
        timeout_seconds: float = Field(
            default=15.0,
            description="HTTP timeout for atlas-api calls.",
        )

    def __init__(self) -> None:
        self.valves = self.Valves()

    # ---- internal helper ----------------------------------------------------
    def _get(self, path: str, params: dict | None = None) -> dict | list:
        url = f"{self.valves.atlas_api_url.rstrip('/')}{path}"
        with httpx.Client(timeout=self.valves.timeout_seconds) as client:
            r = client.get(url, params=params or {})
            r.raise_for_status()
            return r.json()

    # ---- LLM-exposed tools --------------------------------------------------
    def query_transactions(
        self,
        flagged: bool | None = None,
        vendor_id: int | None = None,
        category: str | None = None,
        days_back: int | None = None,
        limit: int = 25,
    ) -> list[dict]:
        """
        Fetch a list of Atlas transactions with optional filters.

        :param flagged: Only return flagged transactions if True; only non-flagged if False; both if None.
        :param vendor_id: Filter to a specific vendor ID.
        :param category: Filter to a specific spend category (e.g. 'travel', 'software_saas').
        :param days_back: Restrict to transactions from the last N days.
        :param limit: Max number of rows (1-200, default 25).
        :return: A list of transaction dicts ordered most-recent first.
        """
        from datetime import datetime, timedelta, timezone

        params: dict = {"limit": min(max(limit, 1), 200)}
        if flagged is not None:
            params["flagged"] = str(flagged).lower()
        if vendor_id is not None:
            params["vendor_id"] = vendor_id
        if category is not None:
            params["category"] = category
        if days_back is not None:
            params["from"] = (datetime.now(timezone.utc) - timedelta(days=days_back)).isoformat()
        return self._get("/transactions", params)

    def get_flagged_transactions(self, limit: int = 20) -> list[dict]:
        """
        Return the most recent flagged transactions awaiting review.

        :param limit: Max number of rows to return (1-200, default 20).
        """
        return self._get("/flagged", {"limit": min(max(limit, 1), 200)})

    def get_transaction_detail(self, transaction_id: int) -> dict:
        """
        Get full details for one transaction, including joined vendor and customer info.

        :param transaction_id: The transaction ID.
        """
        return self._get(f"/transactions/{transaction_id}")

    def get_kpi_snapshot(self, period: str = "7d") -> dict:
        """
        Get headline KPIs (revenue, expenses, flagged count, open cases) for a rolling window.

        :param period: One of '7d', '30d', or 'mtd' (month-to-date). Defaults to '7d'.
        """
        return self._get("/kpi/snapshot", {"period": period})

    def get_vendor_summary(self, vendor_id: int) -> dict:
        """
        Get a spend summary plus recent flagged transactions for a single vendor.

        :param vendor_id: The vendor ID. Use search_vendors first if you only have the name.
        """
        return self._get(f"/vendors/{vendor_id}/summary")

    def search_vendors(self, name_contains: str, limit: int = 20) -> list[dict]:
        """
        Find vendors by partial name match (case-insensitive).

        :param name_contains: Substring of the vendor name.
        :param limit: Max results (1-100, default 20).
        """
        return self._get("/vendors", {"search": name_contains, "limit": min(max(limit, 1), 100)})
