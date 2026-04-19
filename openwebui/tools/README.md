# Atlas Open WebUI tools

Two Python tool files that the Atlas agents call. Each is a thin client over the `atlas-api` service — no SQL or secrets live in the tool itself.

| File | Purpose | Read or write |
|---|---|---|
| `atlas_data.py` | Query transactions, KPIs, vendor summaries, search vendors | Read |
| `atlas_actions.py` | Mark transactions reviewed, open cases, draft vendor emails, trigger workflows | Write |

## Import procedure

1. Open Open WebUI at `https://zivo.tafarax.com`.
2. Go to **Workspace → Tools** (admin only).
3. Click **+** (top right) → **Import from File**, pick one of the `.py` files.
4. Save. Repeat for the other file.
5. Open **Workspace → Models** and assign the tools to each Atlas agent (see `openwebui/models/README.md`).

> Open WebUI auto-installs anything in the file's `requirements:` header (only `httpx` here). The first call may take a few seconds while the package installs.

## Configuring the API base URL

Both tools default to `http://atlas-api:8000` (correct for the docker-compose stack). To point at a different URL, edit the tool's **Valves** in *Workspace → Tools → atlas_data → Settings*.

## Smoke test

After import, open a chat with an agent that has the tool enabled and ask:

> "What were our headline KPIs over the last 7 days?"

The agent should call `get_kpi_snapshot(period="7d")` and return numbers from `atlas-api`.

If the call fails with a connection error: confirm `atlas-api` is healthy with `docker compose ps` and that you can reach it from the open-webui container with `docker compose exec open-webui curl -s http://atlas-api:8000/healthz`.
