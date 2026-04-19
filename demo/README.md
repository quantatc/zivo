# Atlas Operations — demo walkthrough cheat sheet

Use this as a talk-track when running a 10-minute live demo of Zivo for SMB / mid-market ops buyers. The story is built around **Atlas Operations**, an 80-person services firm.

> **Setup before demoing:** confirm `docker compose ps` is all green; visit `https://reports.tafarax.com` once to warm the Evidence build; have `https://zivo.tafarax.com` open in another tab logged in as your demo user.

---

## The story

> "Maya runs operations at Atlas Operations. Every Monday morning she has to: catch up on weekend KPIs, triage flagged transactions, chase a slow-paying vendor, and brief leadership. Today she does it all through Zivo — three persona agents, an automation layer that's been quietly working overnight, and a live dashboard."

## The three agents (in order to demo)

### 1. Atlas Ops Analyst — *the morning briefing*

**Open the model selector → Atlas Ops Analyst → click suggestion:**

> "Show me the headline KPIs for the last 7 days."

Watch it call `get_kpi_snapshot` and return revenue/expenses/flagged counts. **Then ask a follow-up by typing:**

> "Which spend categories drove most of that?"

It will call `query_transactions` (or the category breakdown) and produce a tight summary with TX IDs you can drill into.

**Talk-track:** "Notice the agent never invents a number — every figure traces back to a tool call, and citations point to TX IDs that exist in the dashboard."

### 2. Atlas Fraud Investigator — *triaging weekend exceptions*

**Switch model → Atlas Fraud Investigator → suggestion:**

> "Show me today's flagged transactions and propose triage actions."

It will pull `get_flagged_transactions`, score each LOW/MEDIUM/HIGH, and propose draft case notes for the HIGH-risk ones — but **wait** for confirmation. **Approve one by typing:**

> "Open the case for the largest one with those notes."

The agent calls `create_investigation_case`. Pop over to `https://reports.tafarax.com/case-tracker/` and refresh — the new case appears under "Open cases by age".

**Talk-track:** "The agent doesn't take destructive actions silently. It proposes, you confirm, and the audit trail in Evidence updates immediately."

### 3. Atlas Vendor Concierge — *Maya's outbox*

**Switch model → Atlas Vendor Concierge → suggestion:**

> "Draft a polite reminder to PowerNet Utilities about a late invoice."

It looks up the vendor, summarizes recent activity, then calls `draft_vendor_email` which uses the LLM to produce a clean subject + body. The agent shows it and asks if you want to copy or adjust the tone.

**Talk-track:** "Same workspace, different persona — Maya never leaves Zivo."

## The automation layer (n8n)

**Switch tab to `https://zivo.tafarax.com/n8n/`** and walk through three workflows:

1. **Atlas - 01 Transaction Ingestion** — runs at 7am daily, generates a synthetic batch, fans each one out to the policy check.
2. **Atlas - 02 Fraud Policy Check** — webhook-triggered, calls LiteLLM with an expense-policy prompt, writes the verdict back through `atlas-api`, opens a case if severity = high.
3. **Atlas - 03 Daily Ops Digest** — runs at 8am, pulls KPIs + flagged list, has the LLM write a leadership digest, posts it to a webhook (Slack/email-equivalent).

**Talk-track:** "Two persistent loops are running in the background — one that creates the work, one that summarizes it. The agents in the chat are the human touchpoint; n8n is the always-on operator."

## The dashboard layer (Evidence)

**Switch tab to `https://reports.tafarax.com`** and click through:

- **Index** — exec KPIs at a glance.
- **Cashflow** — daily revenue vs expenses, MTD compare.
- **Fraud Summary** — flagged trend, top flagged vendors.
- **Vendor Watch** — top vendors, watchlist, anomaly detection (z-score outliers).
- **Case Tracker** — open cases by status & age, resolution time.

**Talk-track:** "Same database, three views — chat for ad-hoc, n8n for routine, Evidence for the team-wide picture. One stack."

## Anticipated questions

| Question | Answer |
|---|---|
| "Is this multi-tenant?" | "Today the demo is single-tenant. LiteLLM supports per-key spend caps and OWUI has user/group ACLs — that's where you'd hang multi-tenancy." |
| "How do agents avoid hallucinating numbers?" | "System prompt forbids estimating without a tool call. The Investigator must propose case notes before mutation. Watch the tool-call inspector in OWUI." |
| "Where does the policy live?" | "In the n8n workflow's LLM prompt today. For real customers we'd lift the policy into a config or a Postgres table that both the workflow and a UI can read/edit." |
| "What if LiteLLM is down?" | "`atlas-api` returns a fallback email draft and surfaces the error so the operator knows. Evidence and read-only tools keep working." |
| "Can we white-label this for a specific vertical?" | "Yes — swap the seed (`scripts/seed_atlas.sql`), adjust the agent system prompts, rename the model labels in `litellm/config.yaml`. The architecture stays the same." |

## Reset between demos

```bash
# Reset cases + flags so the Investigator has fresh work
docker compose exec postgres psql -U $POSTGRES_USER -d $POSTGRES_DB <<'SQL'
DELETE FROM investigation_cases WHERE opened_by IN ('open-webui-investigator','n8n.fraud-policy-check');
UPDATE transactions SET reviewed_by = NULL, review_note = NULL WHERE reviewed_by IS NOT NULL;
SQL
```

To wipe entirely and reseed deterministically:

```bash
docker compose down -v
docker compose up -d --build
```
