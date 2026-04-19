# Atlas Open WebUI agents

Three custom Open WebUI Models that make up the Atlas Operations demo cast.

| Model file | Persona | Base model | Tools | Primary use |
|---|---|---|---|---|
| `atlas-ops-analyst.json` | Atlas Ops Analyst | Zivo Balanced (Claude Sonnet 4.5) | atlas_data | Daily KPI Q&A, vendor lookups, spend questions |
| `atlas-fraud-investigator.json` | Atlas Fraud Investigator | Zivo Reasoning (GPT-5) | atlas_data + atlas_actions | Triage flagged transactions, open cases |
| `atlas-vendor-concierge.json` | Atlas Vendor Concierge | Zivo Fast (GPT-5 Mini) | atlas_data + atlas_actions | Draft vendor emails, summarize relationships |

## Prerequisites

1. The two tool files in `openwebui/tools/` must already be imported (see that folder's README).
2. The base LiteLLM models referenced (Zivo Balanced, Zivo Reasoning, Zivo Fast) must already be visible in your model selector. They ship with `litellm/config.yaml`.

## Import procedure

Open WebUI's **Workspace → Models** does not always accept arbitrary JSON imports across versions, so the most reliable path is the manual one:

1. **Workspace → Models → +** (create new).
2. Open the JSON file alongside the form and copy across:
   - **Name** → `name`
   - **Base Model** → `base_model_id`
   - **Description** → `meta.description`
   - **System Prompt** → `params.system`
   - **Temperature, Top P** → `params.temperature`, `params.top_p`
   - **Tags** → `meta.tags`
   - **Suggestion Prompts** (under Advanced) → each `meta.suggestion_prompts[i].content`
3. Under **Tools**, tick the tool names listed in `_zivo_tools` for that JSON.
4. Save.

Repeat for the other two files. Total time: ~5 minutes.

> The `_zivo_tools` field is a Zivo convention used only by this README — Open WebUI ignores it on import.

## Verification

In a fresh chat:

- Pick **Atlas Ops Analyst** → click the suggestion "Show me the headline KPIs for the last 7 days." → tool call should hit `atlas-api`, response should include real numbers.
- Pick **Atlas Fraud Investigator** → "Show me today's flagged transactions and propose triage actions." → expect a structured triage with TX IDs and risk scores.
- Pick **Atlas Vendor Concierge** → "Draft a polite reminder to PowerNet Utilities about a late invoice." → expect a vendor lookup followed by an email draft.

If suggestions don't appear: check that the model is set to **Active** and that you've added at least one entry under **Suggestion Prompts** in the model edit form.
