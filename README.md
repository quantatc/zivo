# Zivo

Zivo is a demo stack for an enterprise AI workspace built on top of Open WebUI
and LiteLLM. The goal is to give you a client-facing environment that feels like
ChatGPT or Claude, but lets you route requests across multiple providers and
later plug in custom agent backends.

## Stack

- Open WebUI v0.8.12 as the user-facing chat interface
- LiteLLM as the LLM gateway and model alias layer
- Postgres for LiteLLM state and admin configuration
- Local branding assets mounted into Open WebUI

## Branding behavior

Two separate things were happening in the old setup:

1. The compose file mounted the logo and favicon into the wrong Open WebUI
   static path, so the image overrides were never being served.
2. Current Open WebUI releases intentionally append `(Open WebUI)` to any custom
   `WEBUI_NAME`. This stack keeps the current release and uses `Zivo Workspace`
   so the UI title reads naturally as `Zivo Workspace (Open WebUI)`.

This keeps the demo on a modern release with the newer features and fixes while
still letting you present the overall product as Zivo.

## Quick start

1. Copy `.env.example` to `.env`.
2. Replace the placeholder secrets in `.env`.
3. Add your `OPENROUTER_API_KEY` in `.env`.
4. Start the stack:

```bash
docker compose up -d
```

5. Open:

- Zivo UI: `http://localhost:3000`
- LiteLLM admin: `http://localhost:4000`

## Production deployment

The current live deployment pattern is:

- Hetzner Cloud `CPX22`
- Cloudflare DNS for `zivo.tafarax.com`
- Caddy on the host for HTTPS and reverse proxy
- Docker Compose running from `/opt/zivo/zivo`

On the server, the repo ended up under `/opt/zivo/zivo`, so all Docker commands
should be run from that directory.

Recommended production `.env` values:

```env
WEBUI_URL=https://zivo.tafarax.com
ENABLE_SIGNUP=false
```

For a fresh production deploy where no admin exists yet, add:

```env
WEBUI_ADMIN_NAME=Your Name
WEBUI_ADMIN_EMAIL=you@tafarax.com
WEBUI_ADMIN_PASSWORD=choose-a-strong-password
```

Use localhost-only port bindings in production so only Caddy is public:

```yaml
open-webui:
  ports:
    - "127.0.0.1:3000:8080"

litellm:
  ports:
    - "127.0.0.1:4000:4000"
```

Minimal Caddy config:

```caddy
zivo.tafarax.com {
    encode gzip zstd
    reverse_proxy 127.0.0.1:3000
}
```

Cloudflare DNS should point `zivo.tafarax.com` to the Hetzner server IP. Start
with `DNS only`, confirm the site works, then switch to `Proxied` and set
Cloudflare SSL mode to `Full (strict)`.

Branding assets:

- [branding/logo.png](/d:/AlgorithmicTradingProjects/zivo/branding/logo.png) is mounted as the app logo
- [branding/favicon.png](/d:/AlgorithmicTradingProjects/zivo/branding/favicon.png) is mounted as the PNG favicon
- `branding/favicon.ico` is mounted as the ICO favicon

## Operations summary

Run all commands from:

```bash
cd /opt/zivo/zivo
```

Useful commands:

- Start or refresh the stack:
  ```bash
  docker compose up -d
  ```
- Check container state:
  ```bash
  docker compose ps
  ```
- Follow Open WebUI logs:
  ```bash
  docker compose logs -f open-webui
  ```
- Follow LiteLLM logs:
  ```bash
  docker compose logs -f litellm
  ```
- Restart LiteLLM after changing model aliases:
  ```bash
  docker compose restart litellm
  ```
- Recreate Open WebUI after changing branding or admin env vars:
  ```bash
  docker compose up -d --force-recreate open-webui
  ```
- Bootstrap the first admin on a fresh deploy:
  Add `WEBUI_ADMIN_NAME`, `WEBUI_ADMIN_EMAIL`, and `WEBUI_ADMIN_PASSWORD` to `.env`, then run:
  ```bash
  docker compose up -d --force-recreate open-webui
  ```
- Pull newer images and restart:
  ```bash
  docker compose pull
  docker compose up -d
  ```
- Check Caddy:
  ```bash
  systemctl status caddy
  journalctl -u caddy -f
  ```

## How model routing works

Open WebUI talks only to LiteLLM:

```text
Browser -> Open WebUI -> LiteLLM -> OpenRouter -> multiple upstream models
```

This is the right demo shape because it gives you one place to manage:

- model aliases
- provider abstraction
- spend controls
- failover and routing later
- tenant-specific model policies later

## Adding models

There are two ways to add models:

1. Add them in the LiteLLM admin UI after the stack is up.
2. Define aliases in [litellm/config.yaml](/d:/AlgorithmicTradingProjects/zivo/litellm/config.yaml).

The demo now ships with an OpenRouter-first model menu:

- `Zivo Free Auto (OpenRouter Free)` -> `openrouter/free`
- `Zivo Free Llama (Llama 3.3 70B)` -> `openrouter/meta-llama/llama-3.3-70b-instruct:free`
- `Zivo Free Qwen (Qwen 3.6 Plus)` -> `openrouter/qwen/qwen3.6-plus:free`
- `Zivo Free OSS (GPT OSS 20B)` -> `openrouter/openai/gpt-oss-20b:free`
- `Zivo Fast (GPT-5 Mini)` -> `openrouter/openai/gpt-5-mini`
- `Zivo Balanced (Claude Sonnet 4.5)` -> `openrouter/anthropic/claude-sonnet-4.5`
- `Zivo Reasoning (GPT-5)` -> `openrouter/openai/gpt-5`
- `Zivo Research (Gemini 2.5 Pro)` -> `openrouter/google/gemini-2.5-pro`
- `Zivo Creative (Grok 4)` -> `openrouter/x-ai/grok-4`

This is deliberate. The UI uses Zivo-first labels for demos, but also shows the
actual model in parentheses so technical users can see what they are selecting.
All of these work through one upstream credential: `OPENROUTER_API_KEY`.

After adding aliases, restart LiteLLM:

```bash
docker compose restart litellm
```

Then refresh Open WebUI and the models should appear in the selector.

## Connecting agent backends later

When you are ready to demo "management agents" or prompt-created agents, keep
Open WebUI as the frontend and attach agent runtimes behind it using
OpenAI-compatible endpoints. That lets you expose:

- normal chat models through LiteLLM
- tool-using agents as separate "models"
- client-specific knowledge or workflows without rewriting the UI

As clients mature, you can keep the same Zivo UX and swap selected aliases from
OpenRouter-backed models to direct provider routes in LiteLLM.

## Files

- [docker-compose.yml](/d:/AlgorithmicTradingProjects/zivo/docker-compose.yml): demo stack
- [.env.example](/d:/AlgorithmicTradingProjects/zivo/.env.example): required environment variables
- [litellm/config.yaml](/d:/AlgorithmicTradingProjects/zivo/litellm/config.yaml): LiteLLM aliases
- [branding/logo.png](/d:/AlgorithmicTradingProjects/zivo/branding/logo.png): app logo
- [branding/favicon.png](/d:/AlgorithmicTradingProjects/zivo/branding/favicon.png): favicon
