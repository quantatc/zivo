---
title: "Statement of Work — Zivo"
subtitle: "Between Zivo and {{CUSTOMER_NAME}}"
author: "Zivo"
date: "{{DATE}}"
---

# 1. Parties

This Statement of Work ("**SOW**") is entered into as of **{{EFFECTIVE_DATE}}** by and between:

- **Provider:** **Zivo** (registered as {{LEGAL_ENTITY_NAME}}), with a registered address at {{PROVIDER_ADDRESS}} ("**Zivo**" or the "**Provider**"); and
- **Customer:** **{{CUSTOMER_NAME}}**, a {{CUSTOMER_ENTITY_TYPE}} with its principal place of business at {{CUSTOMER_ADDRESS}} (the "**Customer**").

Together referred to as the "**Parties**" and individually as a "**Party**".

This SOW is governed by the Master Services Agreement ("**MSA**") executed between the Parties on {{MSA_DATE}}. In the event of conflict between this SOW and the MSA, the MSA shall prevail except where this SOW expressly references and varies a specific MSA term.

---

# 2. Scope of services

Zivo will deliver the **{{TIER_NAME}}** tier of the Zivo platform — a private, multi-component AI workspace combining conversational AI, workflow automation, and live operations intelligence — together with the implementation services described in §3.

The platform comprises:

- A **Conversational AI workspace** built on Open WebUI, with multi-model routing via LiteLLM.
- An **Intelligent automation layer** built on n8n with the Zivo Atlas API.
- A **Live operations intelligence layer** built on Evidence with a per-tenant Postgres datastore.
- A reverse proxy, identity, audit, and backup layer operated by Zivo.

The platform shall be delivered on a **dedicated tenant** (Enterprise tier) or a **siloed compose stack on shared infrastructure** (Managed tier), as specified in §6.

---

# 3. Implementation deliverables

The implementation shall be delivered over an indicative four-week period from the kickoff date as set out below. Concrete dates are confirmed in §7.

## 3.1 Week 1 — Discovery and provisioning

- Stakeholder interviews and integration audit.
- Tenant provisioning on the agreed infrastructure.
- SSO configuration with the Customer's identity provider.
- Connection of {{N_DATA_SOURCES}} priority data sources (read-only credentials supplied by Customer).
- Internal admin training session (90 min).

## 3.2 Week 2 — First production agent and workflow

- One co-pilot agent built against the Customer's highest-volume use case.
- One end-to-end workflow with human-in-the-loop approval.
- Onboarding of the initial pilot user group (3–5 users).

## 3.3 Week 3 — Dashboards and second wave

- Two live dashboards wired to the Customer's data warehouse.
- A second agent + workflow pair.
- Audit-log validation and SLA testing.

## 3.4 Week 4 — Go-live and handover

- Full team onboarded.
- Operational runbook delivered to the Customer's admin contact.
- Quarterly business review cadence scheduled, with the first review booked at week 12.

## 3.5 Acceptance

Each week's deliverables are deemed accepted on the earlier of: (i) Customer's written acceptance, or (ii) seven (7) calendar days after delivery during which Customer has not raised a written objection identifying a material non-conformance.

---

# 4. Customer responsibilities

The Customer agrees to provide, at no cost to Zivo:

- An **executive sponsor** with decision-making authority (≤ 1 hour/week).
- An **admin contact** for technical coordination (≤ 4 hours/week during implementation).
- Read-access credentials for the {{N_DATA_SOURCES}} agreed data sources.
- SSO provider access and the ability to configure SAML / OIDC application registrations.
- A pilot user group of at least three (3) named users available from week 2.
- A documented **success metric** to be measured on day 30, agreed during week 1.

Delays attributable to Customer-side dependencies do not extend Zivo's invoicing schedule (§7) and may extend the implementation timeline by an equivalent number of business days.

---

# 5. Change management

Changes to scope must be requested in writing (email is sufficient). Zivo will respond within three (3) business days with one of:

1. **No-charge accommodation** — minor changes Zivo will absorb.
2. **Workflow build credit** — change is delivered against the Customer's existing credit pool at the prevailing rate (§6.3).
3. **Change order** — a written change order describing scope, fee, and revised timeline, signed by both Parties before work commences.

---

# 6. Fees and payment

## 6.1 Platform fee

| Component                       | Amount                          |
| ------------------------------- | ------------------------------- |
| **Tier**                        | {{TIER_NAME}}                   |
| **Monthly platform fee**        | **{{MONTHLY_FEE}}** USD         |
| **Annual prepay discount**      | {{ANNUAL_DISCOUNT}}             |
| **Term**                        | {{TERM_MONTHS}} months          |
| **Renewal**                     | Automatic, 12-month rolling unless written notice ≥ 60 days before renewal date |

## 6.2 One-time setup fee

| Component                       | Amount                          |
| ------------------------------- | ------------------------------- |
| **Setup fee** (one-time)        | **{{SETUP_FEE}}** USD           |
| **Credit against month one**    | {{SETUP_CREDIT}} if Customer converts from a paid pilot |

## 6.3 Workflow / agent build (time and materials)

Custom agents and workflows beyond the implementation scope (§3) are billed at the **prevailing rate of {{HOURLY_RATE}} USD per engineer-hour**, with a minimum increment of one (1) hour. Customers may pre-purchase **workflow build credit packs** at a discount:

| Pack          | Hours | Investment     | Effective rate |
| ------------- | ----- | -------------- | -------------- |
| Starter pack  | 5     | $1,000         | $200/hr        |
| Growth pack   | 20    | $3,500         | $175/hr        |
| Scale pack    | 50    | $7,500         | $150/hr        |

Credits do not expire while a platform subscription is active.

## 6.4 LLM usage (pass-through)

LLM provider fees (OpenAI, Anthropic, Google, OpenRouter, Azure OpenAI, etc.) are **paid by Customer directly to the provider**. Zivo does not mark up, meter, or invoice for token usage. The Customer is responsible for setting and managing any per-key budget caps within the provider's portal; Zivo will assist on request.

## 6.5 Invoicing and payment terms

- Invoices are issued on the **first business day** of each calendar month.
- Payment terms are **net thirty (30) days** from the invoice date.
- Late payments accrue interest at 1.5% per month or the maximum permitted by law, whichever is lower.
- All fees are exclusive of applicable taxes, which are the Customer's responsibility.

---

# 7. Term, milestones, and termination

## 7.1 Effective date and term

- **Effective date:** {{EFFECTIVE_DATE}}
- **Kickoff date:** {{KICKOFF_DATE}}
- **Initial term:** {{TERM_MONTHS}} months from the kickoff date.

## 7.2 Termination for convenience

Either Party may terminate this SOW for convenience upon **sixty (60) days' written notice**, effective at the end of the then-current billing month. Customer remains liable for fees through the effective termination date.

## 7.3 Termination for cause

Either Party may terminate this SOW immediately for material breach not cured within thirty (30) days of written notice describing the breach.

## 7.4 Effect of termination

Upon termination:

- Zivo will deliver a **complete export** of Customer data within fourteen (14) days, including: chat history, workflow definitions, audit logs, and a Postgres database dump.
- Zivo will continue to provide read-only access to the platform for thirty (30) days post-termination to support migration.
- All accrued fees become immediately due.

---

# 8. Service levels (Enterprise tier)

For the Enterprise tier, Zivo commits to the following service levels.

| Metric                  | Commitment                                                                          |
| ----------------------- | ----------------------------------------------------------------------------------- |
| **Uptime**              | 99.9% measured monthly, excluding scheduled maintenance windows.                    |
| **Maintenance windows** | Communicated ≥ 72 hours in advance; performed Sundays 02:00–04:00 in {{TIMEZONE}}.  |
| **Severity 1 response** | Within 1 business hour; continuous engagement until resolved.                       |
| **Severity 2 response** | Within 4 business hours.                                                            |
| **Severity 3 response** | Within 1 business day.                                                              |
| **Service credits**     | 5% of the monthly platform fee per 0.1% of uptime below the commitment, capped at 30%. |

For the Managed tier, the service-level commitment is **99.5% monthly uptime** with a **best-effort response on standard email-support hours** (Monday–Friday, 09:00–18:00 in {{TIMEZONE}}).

---

# 9. Data protection

Zivo's processing of Customer Personal Data is governed by the **Data Processing Agreement (DPA)** executed between the Parties, which is incorporated by reference. The current sub-processor list is published at `zivoworkspace.ai/legal/subprocessors`. Material changes to the sub-processor list will be communicated to Customer at least thirty (30) days in advance.

Customer Data is stored in {{DATA_REGION}} unless otherwise agreed in writing.

---

# 10. Confidentiality

The Parties acknowledge the confidentiality obligations set out in the MSA. For the avoidance of doubt: this SOW, all pricing and commercial terms herein, and any artifacts produced during implementation are Confidential Information as defined in the MSA.

---

# 11. Signatures

This SOW is executed by the duly authorised representatives of the Parties on the dates set forth below.

\

**For Zivo:**

\

\

___________________________________________

Name: {{ZIVO_SIGNATORY_NAME}}

Title: {{ZIVO_SIGNATORY_TITLE}}

Date:

\

\

**For {{CUSTOMER_NAME}}:**

\

\

___________________________________________

Name:

Title:

Date:

---

# Appendix A — Variable reference

The following placeholders should be replaced before sending. A simple find-and-replace is sufficient.

| Placeholder              | Example                                            |
| ------------------------ | -------------------------------------------------- |
| `{{CUSTOMER_NAME}}`      | Acme Logistics Pty Ltd                             |
| `{{CUSTOMER_ENTITY_TYPE}}` | proprietary limited company                     |
| `{{CUSTOMER_ADDRESS}}`   | 100 Example Way, Cape Town 8001                    |
| `{{LEGAL_ENTITY_NAME}}`  | Zivo (Pty) Ltd                                     |
| `{{PROVIDER_ADDRESS}}`   | (your registered address)                          |
| `{{EFFECTIVE_DATE}}`     | 5 May 2026                                         |
| `{{KICKOFF_DATE}}`       | 12 May 2026                                        |
| `{{MSA_DATE}}`           | 5 May 2026                                         |
| `{{DATE}}`               | 5 May 2026                                         |
| `{{TIER_NAME}}`          | Enterprise                                         |
| `{{MONTHLY_FEE}}`        | 3,000                                              |
| `{{SETUP_FEE}}`          | 5,000                                              |
| `{{SETUP_CREDIT}}`       | 100% creditable                                    |
| `{{ANNUAL_DISCOUNT}}`    | 15% if prepaid annually                            |
| `{{TERM_MONTHS}}`        | 12                                                 |
| `{{HOURLY_RATE}}`        | 200                                                |
| `{{N_DATA_SOURCES}}`     | three (3)                                          |
| `{{TIMEZONE}}`           | SAST (UTC+2)                                       |
| `{{DATA_REGION}}`        | the European Union (Hetzner FSN1, Germany)         |
| `{{ZIVO_SIGNATORY_NAME}}`  | Antony Chibamu                                   |
| `{{ZIVO_SIGNATORY_TITLE}}` | Founder                                          |
