# Zivo Brand Guide

Single source of truth for every customer-facing artifact: proposals, slide decks, social cards, docs.

## Logo

Located in `branding/` at the repo root.

| File | Use |
| --- | --- |
| `logo.png` | Primary mark on dark surfaces |
| `favicon.svg` / `.png` / `.ico` | Browser, app icons |

The mark is an off-white "zi" monogram in a circle. **Always sit it on a dark background.** Do not place it on white or coloured backgrounds without first commissioning a dark variant.

## Colour palette

```
--bg              #08080f    Near-black page background
--surface         #0f0f1a    Card surface
--surface-2       #14142a    Elevated surface

--indigo          #6366f1    Primary accent
--violet          #8b5cf6    Primary accent (gradient pair)
--cyan            #00d4ff    Secondary accent
--emerald         #10b981    Success / positive accent

--text            #f1f5f9    Primary text
--subtle          #94a3b8    Secondary text
--muted           #64748b    Tertiary / disabled

--border          rgba(255,255,255,0.07)
--border-strong   rgba(255,255,255,0.12)
```

**Primary gradient:** `linear-gradient(135deg, #6366f1, #8b5cf6)` — used for primary buttons, accent strokes.

**Hero text gradient:** `linear-gradient(135deg, #ffffff 0%, #a5b4fc 50%, #67e8f9 100%)` — reserve for one or two headline phrases per page.

## Typography

| Role | Family | Notes |
| --- | --- | --- |
| Sans / body | **Inter** | Weights 400, 500, 600, 700, 800 |
| Mono | **JetBrains Mono** | Used in chips, code, labels |

Headings (h1–h4) use weight 700, letter-spacing -0.02em. Body uses weight 400, line-height 1.55–1.7.

Install on Windows: `winget install Inter` and download JetBrains Mono from JetBrains's site. On macOS: `brew install --cask font-inter font-jetbrains-mono`.

## Aesthetic principles

- **Dark-first.** Every customer-facing surface defaults to dark. Light variants are exceptions, not the norm.
- **Glass & glow.** Cards use subtle white-on-white at 3–5% opacity with a 1px translucent border. Behind hero sections, place soft radial glows (indigo, violet, cyan) blurred 60px+.
- **Generous whitespace.** Modern product, not corporate density.
- **Real screenshots, not stock.** Always show the live product. Never use stock photography.
- **No new accent colours.** If you need to differentiate, use weight, opacity, or layout — not new hues.

## Voice

- Direct, confident, no hedging.
- Concrete over abstract: "8 seconds" beats "fast".
- Outcomes first, technology second.
- Never say "AI-powered." We are AI.
- Address the buyer's job, not their stack.
