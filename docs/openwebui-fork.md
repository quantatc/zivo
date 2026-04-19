# Zivo Open WebUI Fork

Zivo should use Open WebUI as the base product, but carry a thin fork for
branding, terminology, and selected product UX. The goal is to keep upstream
updates manageable while making the app feel like Zivo.

## Product Language

Keep **Workspace** as the main product area. It fits the product name and gives
room for agents, tools, files, reports, workflows, and future client workspaces.

Use these terms in the user-facing UI:

| Open WebUI term | Zivo term | Notes |
|---|---|---|
| Models | Agents | Use for persona/tool/knowledge-backed assistants. |
| Model | Agent | Use when users create or select a configured assistant. |
| Base model | Model | Keep for the underlying LLM/provider route. |
| Knowledge | Data Sources | Rename later if needed; not part of the first fork pass. |
| Tools | Tools | Keep unless the UX becomes integration-heavy. |
| Workspace | Workspace | Keep. |

Do not rename backend tables, API fields, or internal variables unless the
feature requires it. UI copy and navigation labels are much cheaper to maintain
than deep internal renames.

## Repository Layout

Keep two repositories:

```text
zivo/
  docker-compose.yml
  docker-compose.fork.yml
  Caddyfile
  branding/
  scripts/

zivo-openwebui/
  fork of https://github.com/open-webui/open-webui
  small Zivo commits only
```

The Compose repo controls deployment. The fork repo controls the custom
Open WebUI image.

## Branch Strategy

Use a small, linear branch for Zivo changes:

```text
upstream/main or upstream tag
  -> zivo/v0.8.12
      commit 1: Zivo branding
      commit 2: Zivo terminology
      commit 3: Agent creation UX
```

Avoid a long-running branch with unrelated experiments. Create separate feature
branches and merge only the changes you want to carry through updates.

## Initial Fork Scope

First pass:

- Keep `Workspace`.
- Change visible `Models` navigation/page language to `Agents`.
- Remove or reword Open WebUI community discovery/promotional copy.
- Set Zivo defaults for name, logo, favicon, and basic text.
- Keep all existing model/provider/backend behavior intact.

Later pass:

- Add a structured "Create Agent" form.
- Save to existing Open WebUI model/assistant structures first.
- Add Zivo-specific database tables only when the existing structures become
  limiting.

## Bootstrapping A Local Fork

From the `zivo` repo:

```bash
OPEN_WEBUI_FORK_REMOTE=git@github.com:YOUR_ORG/zivo-openwebui.git \
  ./scripts/bootstrap-openwebui-fork.sh
```

If you do not have the GitHub fork yet, run without `OPEN_WEBUI_FORK_REMOTE`.
The script will clone upstream into `../zivo-openwebui`, then you can create a
GitHub fork and set the `origin` remote later.

## Building The Fork Image Locally

```bash
OPEN_WEBUI_FORK_IMAGE=zivo-openwebui:v0.8.12-zivo.1 \
  ./scripts/build-openwebui-fork.sh
```

Then run the stack with the fork override:

```bash
OPEN_WEBUI_IMAGE=zivo-openwebui:v0.8.12-zivo.1 \
  docker compose -f docker-compose.yml -f docker-compose.fork.yml up -d open-webui
```

For production, prefer pushing the image to a registry and setting
`OPEN_WEBUI_IMAGE` in `.env`:

```env
OPEN_WEBUI_IMAGE=ghcr.io/YOUR_ORG/zivo-openwebui:v0.8.12-zivo.1
```

Then deploy normally:

```bash
docker compose pull open-webui
docker compose up -d --force-recreate open-webui
```

## Updating From Upstream

In the `zivo-openwebui` repo:

```bash
git fetch upstream --tags
git switch zivo/v0.8.12
git rebase upstream/main
```

Resolve conflicts only in the small Zivo commits. Rebuild and test before
deploying:

```bash
docker build -t ghcr.io/YOUR_ORG/zivo-openwebui:v0.8.13-zivo.1 .
```

## Maintenance Rules

- Keep Zivo changes source-level, not container `sed` patches.
- Keep fork commits small and themed.
- Do not rename Open WebUI internals just for terminology.
- Do not use `latest` for production Open WebUI images.
- Test login, chat, model selection, tools, knowledge, and admin pages after
  every upstream rebase.
