# Atlas demo n8n workflows

Three importable n8n workflows that drive the Atlas Operations demo.

| File | Trigger | What it does |
|---|---|---|
| `01-transaction-ingestion.json` | Cron 7am daily | Generates 5-15 synthetic transactions, POSTs each to `atlas-api`, then fans each one out to the policy-check workflow |
| `02-fraud-policy-check.json` | Webhook `/webhook/fraud-policy-check` | Calls LiteLLM to evaluate the transaction against expense policy, writes the verdict back to `atlas-api`, opens an investigation case if severity is `high`, and responds with the verdict |
| `03-daily-ops-digest.json` | Cron 8am daily | Pulls KPIs + flagged list from `atlas-api`, asks LiteLLM for a leadership digest, posts the markdown to `OPS_DIGEST_WEBHOOK_URL` |

## Required environment

These workflows reference two env vars on the n8n container:

| Env var | Used by | Purpose |
|---|---|---|
| `LITELLM_MASTER_KEY` | workflows 02, 03 | Bearer token for the LiteLLM API |
| `OPS_DIGEST_WEBHOOK_URL` | workflow 03 | Where the digest is posted (e.g. a Slack webhook or `https://webhook.site/<uuid>` for the demo) |

`LITELLM_MASTER_KEY` is already set in your `.env`. Add `OPS_DIGEST_WEBHOOK_URL` and rerun `docker compose up -d n8n n8n-worker`. If unset, workflow 03 falls back to a placeholder URL and the call will 404 — that's fine, the rest still runs.

## Import procedure

1. Open n8n at `https://zivo.tafarax.com/n8n/`.
2. **Workflows → Add workflow → Import from file** (or drag the JSON in).
3. Repeat for all three files.
4. Open each workflow and click **Activate** (top right).
5. For workflow 02, copy the production webhook URL — it is `<base>/webhook/fraud-policy-check`. Workflow 01 already targets it through `atlas-api`'s `/actions/trigger-workflow` proxy, so you usually do not need to call it directly.

## Smoke test

```bash
# Trigger ingestion manually (workflow 01) — open it in n8n and click "Execute workflow"
# Then verify rows in atlas-api:
curl -s http://localhost:8088/transactions?limit=5 | jq

# Fire the policy-check webhook with a fake high-amount transaction
curl -s -X POST http://localhost:8088/actions/trigger-workflow \
  -H 'Content-Type: application/json' \
  -d '{"workflow_slug":"fraud-policy-check","payload":{"id":1,"amount":7500,"category":"travel","vendor_name":"Cascade Hotels","description":"3 nights conference"}}'

# Run the digest workflow manually and watch n8n execution logs
```

## Notes

- Workflows ship with `active: false`. Activate them after import — this prevents accidental cron firing during setup.
- All HTTP calls are container-internal (`http://atlas-api:8000`, `http://litellm:4000`). They do **not** need to traverse Caddy.
- Tag `atlas-demo` is applied to each workflow so they are easy to filter in the n8n list.
