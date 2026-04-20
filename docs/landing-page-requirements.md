# Zivo Landing Page — Product Requirements Document

**URL:** `zivo.tafarax.com`  
**App URL:** `app.tafarax.com`  
**Version:** 1.0  
**Date:** 2026-04-20  
**Audience:** SMB and mid-market operations buyers

---

## 1. Objective

Build a high-conversion, visually stunning dark-theme landing page that positions Zivo as a premium enterprise AI workspace. Visitors should feel in 5 seconds that this is serious infrastructure — not a toy. Primary CTA: book a demo or start a trial on `app.tafarax.com`.

---

## 2. Design Direction

### 2.1 Visual Language

| Token | Value |
|---|---|
| Background | `#08080f` (near-black, slightly blue-tinted) |
| Surface cards | `#0f0f1a` with `1px solid rgba(255,255,255,0.07)` border |
| Primary accent | `#6366f1` (indigo/electric violet) |
| Secondary accent | `#00d4ff` (cyan glow) |
| Success / live | `#10b981` (emerald) |
| Text primary | `#f1f5f9` |
| Text muted | `#64748b` |
| Gradient hero | `135deg, #6366f1 0%, #8b5cf6 50%, #00d4ff 100%` |

### 2.2 Aesthetic Pillars

- **Glassmorphism cards** — `backdrop-filter: blur(20px)` on feature cards and testimonial blocks
- **Gradient glow spots** — 2–3 large radial gradient blobs positioned behind hero and feature sections (subtle, ~15% opacity)
- **Fine dot-grid background** — SVG dot pattern at 5% opacity layered over the base colour
- **Animated gradient borders** — feature cards animate border colour on hover via `@keyframes`
- **Motion** — entrance animations with `IntersectionObserver` (fade-up, stagger 80ms per card). No autoplay video. No infinite loops that burn CPU.
- **Typography** — `Inter` (headings: 700–900 weight; body: 400). Headline sizes: H1 `clamp(2.5rem, 6vw, 5rem)`, H2 `clamp(1.8rem, 4vw, 3rem)`
- **Logo** — use `branding/logo.png` and `branding/favicon.svg`

### 2.3 Anti-patterns to Avoid

- No light mode. No toggle.
- No stock photos of people shaking hands.
- No clipart illustrations. Use geometric/abstract SVG glyphs and real UI screenshots.
- No carousels with auto-advance.

---

## 3. Tech Stack

| Layer | Choice | Reason |
|---|---|---|
| Framework | **Astro** (static output) | Zero JS by default, fast, great DX, deploys as a single container |
| Styling | **Tailwind CSS v4** | Utility-first, consistent token system |
| Animations | **GSAP (free tier)** + CSS transitions | Performant, no layout thrash |
| Icons | **Lucide** (SVG sprite) | Consistent, sharp at all sizes |
| Container | `nginx:alpine` serving `/dist` | Tiny image, served via Caddy on host |
| Analytics | **Plausible** (self-hosted or cloud) | Privacy-friendly, no cookie banner needed |

Deploy as a Docker service alongside the existing stack. Caddy routes `zivo.tafarax.com` → landing container on `127.0.0.1:3200`; `app.tafarax.com` → Open WebUI fork on `127.0.0.1:3000`.

---

## 4. Page Sections

### Section 1 — Navigation Bar (sticky)

- Left: Zivo logo + wordmark
- Center (desktop): anchor links — Features · How It Works · Use Cases · Pricing
- Right: `Sign in` (ghost button → `app.tafarax.com`) + `Get a Demo` (filled indigo button)
- On scroll >80px: add `backdrop-blur` + border-bottom to nav
- Mobile: hamburger → full-screen overlay menu

---

### Section 2 — Hero

**Goal:** immediate comprehension + desire in under 5 seconds.

**Layout:** Two-column on desktop (text left, visual right). Single-column on mobile.

**Headline options (pick one):**
> "Your ops team's AI brain — live in a day."

> "The AI workspace ops teams actually use."

> "From data chaos to decisions. Powered by AI."

**Subheadline (40–60 words):**
> Zivo brings together AI chat agents, no-code workflow automation, and real-time business intelligence in one unified workspace. Deploy on your infrastructure. Connect your data. Let your team focus on what matters.

**CTAs:**
- Primary: `Start Free Trial →` → `app.tafarax.com/signup`
- Secondary: `Watch the Demo` → scrolls to or opens inline demo video embed

**Visual (right column):**
- Animated product mockup: browser chrome showing the Atlas AI chat interface, with a subtle "typing" animation and one completed response visible
- Beneath it: three small floating badges with glow shadows — `AI Agents`, `Workflow Automation`, `BI Dashboards` — animated in with stagger
- Background: large indigo glow blob, partially behind mockup

**Trust bar below hero (full width):**
> "Trusted infrastructure. Zero vendor lock-in."  
> Logos row (greyscale, low opacity): Open WebUI · n8n · PostgreSQL · Docker · Caddy · LiteLLM

---

### Section 3 — The Problem (Pain Points)

**Heading:** "Your team is drowning in tools that don't talk to each other."

Three pain cards in a row (glassmorphism, icon + short copy):

| Icon | Title | Body |
|---|---|---|
| `AlertTriangle` | Scattered context | "Analysts switch between 6+ tools to answer one question. Hours lost every day." |
| `Shuffle` | Manual handoffs | "Approvals, escalations, and reports all live in someone's inbox — or Slack thread." |
| `BarChart2` | Stale data | "By the time the dashboard loads, the decision is already overdue." |

---

### Section 4 — Solution / Features

**Heading:** "One workspace. Every AI capability your ops team needs."

**Layout:** 3-column feature grid (cards) + one wide "showcase" card below

**Feature Cards:**

**1 — AI Agents (indigo accent)**
- Icon: `Bot`
- Title: "Purpose-built AI agents"
- Body: "Deploy specialist agents trained on your operations — vendor management, fraud analysis, or custom workflows. Chat-native, context-aware, always on."
- Tag: `Powered by LiteLLM · OpenRouter`

**2 — Workflow Automation (cyan accent)**
- Icon: `Workflow`
- Title: "No-code automation engine"
- Body: "Build multi-step workflows visually. Trigger from webhooks, schedules, or agent outputs. 400+ integrations out of the box."
- Tag: `Powered by n8n`

**3 — BI Dashboards (emerald accent)**
- Icon: `BarChart3`
- Title: "Live intelligence dashboards"
- Body: "SQL-first dashboards that connect directly to your database. Version-controlled, shareable, always reflecting live data."
- Tag: `Powered by Evidence`

**Wide Showcase Card (below the 3):**
- Split: left side = feature list checklist, right side = embedded or static screenshot of Atlas Ops dashboard
- Headline: "Atlas Operations — a full enterprise demo, out of the box"
- Bullets: Fraud Investigator agent · Ops Analyst agent · Vendor Concierge agent · 3 automated workflows · 4 live dashboards
- CTA: `Explore the Demo →`

---

### Section 5 — How It Works

**Heading:** "From zero to AI-powered ops in three steps."

Three numbered steps with connecting line (desktop) or vertical stack (mobile):

| Step | Title | Detail |
|---|---|---|
| 01 | Deploy in minutes | Clone the repo, add your env vars, run `docker compose up`. Caddy handles TLS automatically. |
| 02 | Connect your data | Point Zivo at your existing PostgreSQL or connect via n8n's 400+ integrations. No data leaves your infra. |
| 03 | Put your team to work | Invite your team, assign agents, build workflows. Your ops AI workspace is live. |

---

### Section 6 — Use Cases

**Heading:** "Built for the teams that keep operations running."

Tabbed or card-switcher layout. Three tabs:

**Tab 1 — Operations & Finance**
- Scenario: "Spot a vendor payment anomaly at 9am. The Fraud Investigator agent has already flagged it, drafted an incident report, and triggered a review workflow — before your analyst's coffee is brewed."

**Tab 2 — Customer Operations**
- Scenario: "A high-value client asks about their SLA compliance. The Ops Analyst agent pulls the data, compares against the contract, and drafts a response in seconds."

**Tab 3 — Executive Reporting**
- Scenario: "Monday morning. The weekly ops health dashboard is already generated, annotated by the AI, and waiting in the shared workspace — no manual pulling required."

---

### Section 7 — Architecture / Trust

**Heading:** "Enterprise-grade. Your data stays yours."

Two-column: left = copy; right = architecture diagram (SVG, dark-themed)

**Left copy bullets:**
- Self-hosted on your infrastructure — no SaaS data sharing
- Postgres + Redis + Chroma vector store, all under your control
- LiteLLM proxy — swap model providers without changing a line of code
- Caddy-managed TLS, zero exposed internal ports
- Open-source core components — no black boxes

**Right diagram:** simplified stack diagram showing: User Browser → Caddy → [Open WebUI Fork | n8n | Evidence] → [LiteLLM → OpenRouter/Anthropic/OpenAI] and [PostgreSQL | Redis | Chroma]. Clean SVG, dark with glow lines.

---

### Section 8 — Social Proof / Testimonials (Placeholder)

**Heading:** "What early adopters say"

Three glassmorphism quote cards. If real quotes unavailable at launch, use placeholders marked clearly in code as `<!-- TODO: replace with real quote -->`.

Placeholder structure:
> "Zivo replaced three separate tools we were paying for. The n8n + AI agent combo handles our weekly vendor reconciliation without a single human touch."  
> — *Head of Operations, [Company]*

---

### Section 9 — Pricing

**Heading:** "Simple, transparent pricing."

Three tiers in a card row. Middle card highlighted (recommended):

| Tier | Price | For |
|---|---|---|
| **Starter** | `$0 / self-hosted` | Teams that want to run it themselves. Full feature set. Community support. |
| **Pro** ⭐ | `$299 / mo` | Managed deployment on your infra. Setup included. Email support. |
| **Enterprise** | `Custom` | Multi-tenant, SSO, SLA, custom agents. Contact us. |

> Note: Adjust actual pricing as decided. These are placeholder values — mark with `<!-- PRICING: confirm before launch -->` in code.

---

### Section 10 — Final CTA

Full-width dark section with gradient glow background.

**Headline:** "Ready to give your ops team an AI advantage?"

**Subheadline:** "Deploy in an afternoon. Results from day one."

**CTAs:**
- Primary: `Start Free Trial →` → `app.tafarax.com/signup`
- Secondary: `Talk to us` → `mailto:` or Calendly link

---

### Section 11 — Footer

Three columns:
- **Col 1:** Logo + one-liner tagline + social icons (GitHub, LinkedIn, X/Twitter)
- **Col 2:** Links — Product · Docs · Changelog · Status
- **Col 3:** Company — About · Contact · Privacy Policy · Terms

Bottom bar: `© 2026 Zivo · Built on open source · zivo.tafarax.com`

---

## 5. Performance Requirements

| Metric | Target |
|---|---|
| Lighthouse Performance | ≥ 95 |
| LCP | < 1.8s |
| CLS | < 0.05 |
| FID / INP | < 100ms |
| Total page weight | < 500kb (excl. images) |
| Images | WebP, lazy-loaded, explicit `width`/`height` |
| Fonts | Self-hosted Inter via `@font-face`, `font-display: swap` |

---

## 6. SEO & Meta

```html
<title>Zivo — Enterprise AI Workspace for Operations Teams</title>
<meta name="description" content="Zivo brings AI agents, no-code automation, and live BI dashboards into one self-hosted workspace. Built for SMB and mid-market ops teams." />
<meta property="og:image" content="/og-image.png" />  <!-- 1200×630, dark branded -->
<meta property="og:title" content="Zivo — Enterprise AI Workspace" />
<link rel="canonical" href="https://zivo.tafarax.com/" />
```

Sitemap: `/sitemap.xml` (Astro generates automatically).  
Robots: allow all.

---

## 7. Accessibility

- WCAG 2.1 AA contrast ratios on all text/background combinations
- All interactive elements keyboard-navigable
- `aria-label` on all icon-only buttons
- `prefers-reduced-motion` media query wraps all GSAP animations
- Semantic HTML: `<header>`, `<main>`, `<section>`, `<footer>`, `<nav>`

---

## 8. Responsive Breakpoints

| Breakpoint | Layout notes |
|---|---|
| Mobile `< 640px` | Single column throughout. Nav collapses to hamburger. |
| Tablet `640–1024px` | 2-column where 3 doesn't fit. Nav links visible. |
| Desktop `> 1024px` | Full layout as described. Max-width `1280px`, centred. |

---

## 9. Deployment

Add to `docker-compose.yml`:

```yaml
landing:
  build:
    context: ./landing
    dockerfile: Dockerfile
  container_name: zivo-landing
  restart: unless-stopped
  expose:
    - "80"
```

Add to `Caddyfile`:

```
zivo.tafarax.com {
  reverse_proxy zivo-landing:80
}

app.tafarax.com {
  reverse_proxy open-webui:3000
}
```

`landing/Dockerfile`:

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
```

---

## 10. Open Items / Decisions Needed

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | Final headline copy confirmed | Product | Open |
| 2 | Real testimonial quotes | Sales | Open |
| 3 | Pricing tiers confirmed | Business | Open |
| 4 | Demo video recorded | Product | Open |
| 5 | OG image designed (`1200×630`) | Design | Open |
| 6 | `app.tafarax.com` DNS + Caddy config | DevOps | Open |
| 7 | Plausible analytics instance | DevOps | Open |
| 8 | Calendly / contact link for Enterprise CTA | Sales | Open |

---

## 11. File Structure (proposed)

```
landing/
├── Dockerfile
├── astro.config.mjs
├── tailwind.config.mjs
├── package.json
├── public/
│   ├── favicon.svg         ← copy from branding/
│   ├── logo.png            ← copy from branding/
│   ├── og-image.png        ← TODO: design
│   └── fonts/
│       └── inter/
├── src/
│   ├── layouts/
│   │   └── Base.astro
│   ├── components/
│   │   ├── Nav.astro
│   │   ├── Hero.astro
│   │   ├── Features.astro
│   │   ├── HowItWorks.astro
│   │   ├── UseCases.astro
│   │   ├── Architecture.astro
│   │   ├── Pricing.astro
│   │   ├── Testimonials.astro
│   │   ├── FinalCTA.astro
│   │   └── Footer.astro
│   ├── pages/
│   │   └── index.astro
│   └── styles/
│       └── global.css
```
