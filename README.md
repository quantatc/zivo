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

- `Zivo Fast` -> `openrouter/openai/gpt-5-mini`
- `Zivo Balanced` -> `openrouter/anthropic/claude-sonnet-4.5`
- `Zivo Reasoning` -> `openrouter/openai/gpt-5`
- `Zivo Research` -> `openrouter/google/gemini-2.5-pro`
- `Zivo Creative` -> `openrouter/x-ai/grok-4`

This is deliberate. Instead of exposing raw vendor names in the UI, the demo
uses job-to-be-done labels that are easier to sell to clients. All of them work
through one upstream credential: `OPENROUTER_API_KEY`.

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
