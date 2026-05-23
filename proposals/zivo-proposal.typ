// =============================================================================
// Zivo — Enterprise AI Workspace Proposal (master template)
// -----------------------------------------------------------------------------
// Compile:
//   typst compile zivo-proposal.typ out/zivo-proposal-generic.pdf
// Per-prospect:
//   typst compile --input prospect="Acme Corp" --input industry="logistics" \
//       zivo-proposal.typ out/zivo-proposal-acme.pdf
// =============================================================================

// ---------- Per-prospect inputs ----------------------------------------------
#let prospect       = sys.inputs.at("prospect",     default: "Your Team")
#let industry       = sys.inputs.at("industry",     default: "operations")
#let prepared-by    = sys.inputs.at("prepared_by",  default: "Antony Chibamu · Founder, Zivo")
#let contact-email  = sys.inputs.at("email",        default: "hello@zivoworkspace.ai")
#let prepared-date  = sys.inputs.at("date",         default: datetime.today().display("[month repr:long] [day], [year]"))
#let version-tag    = sys.inputs.at("version",      default: "v1.0")

// ---------- Brand tokens -----------------------------------------------------
#let bg            = rgb("#08080f")
#let surface       = rgb("#0f0f1a")
#let surface-2     = rgb("#14142a")
#let border        = rgb(255, 255, 255, 18)
#let border-strong = rgb(255, 255, 255, 36)
#let indigo        = rgb("#6366f1")
#let violet        = rgb("#8b5cf6")
#let cyan          = rgb("#00d4ff")
#let emerald       = rgb("#10b981")
#let amber         = rgb("#f59e0b")
#let rose          = rgb("#f43f5e")
#let text-primary  = rgb("#f1f5f9")
#let text-subtle   = rgb("#94a3b8")
#let text-muted    = rgb("#64748b")
#let accent-light  = rgb("#a5b4fc")
#let accent-cyan   = rgb("#67e8f9")

// ---------- Document & page defaults ----------------------------------------
#set document(
  title: "Zivo — Proposal for " + prospect,
  author: "Zivo",
  description: "Enterprise AI workspace proposal",
)

#set page(
  paper: "a4",
  margin: (top: 24mm, bottom: 24mm, left: 20mm, right: 20mm),
  fill: bg,
  header: context {
    let n = counter(page).get().first()
    if n > 1 {
      grid(
        columns: (1fr, auto),
        align(left)[
          #text(size: 8pt, fill: text-muted, font: "JetBrains Mono")[
            ZIVO · PROPOSAL FOR #upper(prospect)
          ]
        ],
        align(right)[
          #text(size: 8pt, fill: text-muted, font: "JetBrains Mono")[
            #version-tag · #prepared-date
          ]
        ],
      )
      v(2pt)
      line(length: 100%, stroke: 0.4pt + border)
    }
  },
  footer: context {
    let n = counter(page).get().first()
    if n > 1 {
      line(length: 100%, stroke: 0.4pt + border)
      v(2pt)
      grid(
        columns: (1fr, auto, 1fr),
        align(left)[
          #text(size: 8pt, fill: text-muted, font: "JetBrains Mono")[
            zivoworkspace.ai
          ]
        ],
        align(center)[
          #text(size: 8pt, fill: text-subtle, weight: 600, font: "JetBrains Mono")[
            #n
          ]
        ],
        align(right)[
          #text(size: 8pt, fill: text-muted, font: "JetBrains Mono")[
            CONFIDENTIAL
          ]
        ],
      )
    }
  },
)

#set text(
  font: ("Inter", "Segoe UI", "Helvetica Neue", "Liberation Sans"),
  size: 10pt,
  fill: text-primary,
  weight: 400,
)
#set par(leading: 0.65em, justify: false, first-line-indent: 0pt)

#show heading: set text(weight: 700)
#show heading.where(level: 1): it => {
  v(8pt)
  text(size: 26pt, weight: 800, fill: text-primary, tracking: -0.5pt, it.body)
  v(4pt)
}
#show heading.where(level: 2): it => {
  v(6pt)
  text(size: 16pt, weight: 700, fill: text-primary, tracking: -0.3pt, it.body)
  v(2pt)
}
#show heading.where(level: 3): it => {
  text(size: 11pt, weight: 700, fill: text-primary, it.body)
  v(1pt)
}

// ---------- Helpers ----------------------------------------------------------

#let gradient-text(content) = text(
  fill: gradient.linear(
    rgb("#ffffff"),
    accent-light,
    accent-cyan,
    angle: 135deg,
  ),
  weight: 800,
  content,
)

#let eyebrow(content) = box(
  fill: rgb(99, 102, 241, 26),
  stroke: 0.6pt + rgb(99, 102, 241, 90),
  radius: 100pt,
  inset: (x: 10pt, y: 4pt),
)[#text(size: 8pt, fill: accent-light, font: "JetBrains Mono", weight: 500)[#upper(content)]]

#let chip(content, color: text-subtle, bg-color: none) = box(
  fill: if bg-color != none { bg-color } else { rgb(255, 255, 255, 12) },
  stroke: 0.5pt + border,
  radius: 100pt,
  inset: (x: 7pt, y: 2pt),
)[#text(size: 7pt, fill: color, font: "JetBrains Mono", weight: 500)[#upper(content)]]

#let card(body, fill-color: surface, stroke-color: border, pad: 14pt) = block(
  width: 100%,
  fill: fill-color,
  stroke: 0.6pt + stroke-color,
  radius: 10pt,
  inset: pad,
  breakable: false,
  body,
)

#let stat(value, label, color: indigo) = card(
  fill-color: surface,
  stroke-color: border-strong,
  pad: 11pt,
)[
  #text(size: 22pt, weight: 800, fill: color, tracking: -0.5pt, value)
  #v(1pt)
  #text(size: 8pt, fill: text-subtle, weight: 500, label)
]

#let bullet(content, color: indigo) = grid(
  columns: (10pt, 1fr),
  column-gutter: 8pt,
  align(top + center)[
    #v(3pt)
    #box(
      width: 6pt, height: 6pt, radius: 100%,
      fill: color.transparentize(60%),
      stroke: 0.6pt + color,
    )
  ],
  text(fill: text-primary, content),
)

#let check(content, color: emerald) = grid(
  columns: (12pt, 1fr),
  column-gutter: 8pt,
  align(top)[
    #v(2pt)
    #text(fill: color, weight: 800, size: 9pt)[\u{2713}]
  ],
  text(fill: text-primary, size: 9.5pt, content),
)

#let label-strong(t) = text(size: 7.5pt, fill: text-muted, weight: 600, font: "JetBrains Mono")[#upper(t)]

#let divider() = {
  v(8pt)
  line(length: 100%, stroke: 0.4pt + border)
  v(8pt)
}

// =============================================================================
// PAGE 1 — COVER
// =============================================================================
#page(
  margin: 0pt,
  header: none,
  footer: none,
  fill: bg,
  background: {
    place(top + left, rect(width: 100%, height: 100%, fill: bg))
    place(top + left, dx: -120pt, dy: -120pt,
      circle(radius: 320pt, fill: gradient.radial(
        indigo.transparentize(40%), bg.transparentize(100%),
      ))
    )
    place(bottom + right, dx: 120pt, dy: 120pt,
      circle(radius: 280pt, fill: gradient.radial(
        cyan.transparentize(50%), bg.transparentize(100%),
      ))
    )
    place(center + horizon, dx: -60pt, dy: 60pt,
      circle(radius: 240pt, fill: gradient.radial(
        violet.transparentize(50%), bg.transparentize(100%),
      ))
    )
  },
)[
  #pad(x: 28mm, y: 28mm)[
    // Top bar: logo + URL
    #grid(
      columns: (auto, 1fr),
      align(left)[
        #image("assets/logo.png", width: 36pt)
      ],
      align(right)[
        #text(size: 9pt, fill: text-subtle, font: "JetBrains Mono")[zivoworkspace.ai]
      ],
    )

    #v(58mm)

    // Eyebrow
    #eyebrow("Proposal · " + version-tag)

    #v(12pt)

    // Title block
    #set par(leading: 0.5em)
    #text(size: 44pt, weight: 800, tracking: -1.5pt)[
      Every team. \
      Every workflow. \
      #gradient-text[One AI workspace.]
    ]

    #v(16pt)

    #set par(leading: 0.65em)
    #text(size: 12pt, fill: text-subtle)[
      A proposal for #text(fill: text-primary, weight: 700)[#prospect] to deploy a
      private, enterprise-grade AI workspace combining intelligent agents,
      workflow automation, and live operations intelligence — in a single
      tenant your team owns end to end.
    ]

    #v(28pt)

    // Bottom bar: prepared / date
    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 16pt,
      align(left)[
        #label-strong("Prepared for")
        #v(2pt)
        #text(size: 11pt, weight: 600, fill: text-primary)[#prospect]
      ],
      align(left)[
        #label-strong("Prepared by")
        #v(2pt)
        #text(size: 11pt, weight: 600, fill: text-primary)[#prepared-by]
      ],
      align(left)[
        #label-strong("Date")
        #v(2pt)
        #text(size: 11pt, weight: 600, fill: text-primary)[#prepared-date]
      ],
    )
  ]
]

// =============================================================================
// PAGE 2 — EXECUTIVE SUMMARY
// =============================================================================
#eyebrow("Executive Summary")
#v(10pt)
= The AI workspace #gradient-text[#prospect] will actually use.

#v(6pt)
#text(size: 11pt, fill: text-subtle)[
  Most enterprise AI initiatives stall not because the technology fails, but
  because the workflow does. Chat lives in one tool, automation in another,
  and the data that should connect them is locked behind dashboards your team
  doesn't open. Zivo collapses all three into one private workspace —
  conversational AI, workflow automation, and live operations intelligence —
  deployed in a tenant only you control.
]

#v(14pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 12pt,
  stat("70%", "of knowledge-worker time goes to coordination, not output. Zivo automates the coordination layer.", color: indigo),
  stat("2 weeks", "from kickoff to your first production agent and workflow — not 6 months.", color: cyan),
  stat("100%", "data sovereignty. Your tenant, your keys, your audit log. No shared model training.", color: emerald),
)

#v(16pt)

#card(pad: 16pt, fill-color: surface-2, stroke-color: border-strong)[
  === Inside this proposal
  #v(6pt)
  #grid(
    columns: (1fr, 1fr),
    row-gutter: 4pt,
    column-gutter: 16pt,
    text(size: 9.5pt)[*The problem* and what it costs your team today],
    text(size: 9.5pt)[*Demo case study* — Atlas Operations, end to end],
    text(size: 9.5pt)[*A day in the life* — before and after Zivo],
    text(size: 9.5pt)[*Integrations* — your existing stack, connected],
    text(size: 9.5pt)[*The Zivo platform* — three pillars, one workspace],
    text(size: 9.5pt)[*Deployment options & pricing* — Managed and Enterprise],
    text(size: 9.5pt)[*Architecture* — what runs where, who has access],
    text(size: 9.5pt)[*Implementation, security, and next steps*],
  )
]

#v(14pt)

#card(fill-color: surface, stroke-color: indigo.transparentize(70%))[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 12pt,
    align(top)[
      #box(width: 26pt, height: 26pt, radius: 6pt, fill: indigo.transparentize(80%), stroke: 0.6pt + indigo.transparentize(50%))[
        #align(center + horizon)[#text(size: 14pt, fill: accent-light, weight: 700)[#sym.arrow.r]]
      ]
    ],
    [
      *The proposed next step:* a 30-day paid pilot for #prospect's #industry team.
      One agent, one workflow, one dashboard, one outcome metric you choose. Fixed
      fee. Convertible to an annual contract at a 15% discount.
    ],
  )
]

#pagebreak()

// =============================================================================
// PAGE 3 — THE PROBLEM
// =============================================================================
#eyebrow("The Problem")
#v(10pt)
= Three things break in every growing #gradient-text[operations team.]

#v(10pt)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 12pt,
  card(pad: 16pt)[
    #chip("01", color: accent-light, bg-color: indigo.transparentize(80%))
    #v(8pt)
    === AI is stuck in a chat box.
    #v(4pt)
    #text(fill: text-subtle, size: 9.5pt)[
      Your team uses ChatGPT for one-off questions, but it can't see your
      data, can't take action, and pasting company information into a
      consumer tool is a security review waiting to happen.
    ]
  ],
  card(pad: 16pt)[
    #chip("02", color: accent-cyan, bg-color: cyan.transparentize(80%))
    #v(8pt)
    === Automation lives somewhere else.
    #v(4pt)
    #text(fill: text-subtle, size: 9.5pt)[
      Zapier and Make handle the rote work, but they don't reason. Every
      branching condition becomes another fragile rule, and nobody on your
      team owns the spaghetti.
    ]
  ],
  card(pad: 16pt)[
    #chip("03", color: rgb("#6ee7b7"), bg-color: emerald.transparentize(80%))
    #v(8pt)
    === Reports live in a third tool.
    #v(4pt)
    #text(fill: text-subtle, size: 9.5pt)[
      Your BI tool has the answers — six clicks deep in a dashboard nobody
      opens. By the time someone notices the anomaly, it's last week's
      problem.
    ]
  ],
)

#v(20pt)

#card(fill-color: surface-2, pad: 18pt, stroke-color: border-strong)[
  #grid(
    columns: (auto, 1fr, auto),
    column-gutter: 18pt,
    align(horizon + center)[
      #text(size: 36pt, weight: 800, fill: amber)[!]
    ],
    [
      === The cost is invisible — until you measure it.
      #v(4pt)
      #text(fill: text-subtle, size: 10pt)[
        Industry research consistently puts knowledge-worker context-switching
        at 20–30% of every working day. For a 50-person operations team, that
        is roughly *2,000 hours per month* of pure overhead — gone to swivel-chair
        copy/paste between the three tools above. The shape of the problem isn't
        a missing feature. It's a missing fabric.
      ]
    ],
    [],
  )
]

#v(14pt)

#text(size: 10pt, fill: text-subtle)[
  Zivo replaces the fabric. One workspace where your team asks the question,
  the agent reasons over your data, the workflow takes the action, and the
  dashboard reflects the outcome — without leaving the conversation.
]

#pagebreak()

// =============================================================================
// PAGE 4 — A DAY IN THE LIFE
// =============================================================================
#eyebrow("A Day In The Life")
#v(10pt)
= Before Zivo, after Zivo. #gradient-text[Same person, very different day.]

#v(14pt)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 16pt,
  // BEFORE column
  card(pad: 16pt, stroke-color: rose.transparentize(60%))[
    #chip("BEFORE", color: rgb("#fda4af"), bg-color: rose.transparentize(80%))
    #v(8pt)
    === Sarah, Ops Lead. Tuesday.
    #v(8pt)
    #stack(spacing: 12pt,
      [
        #label-strong("8:00 am")
        #v(2pt)
        #text(size: 9.5pt, fill: text-subtle)[Opens 6 browser tabs: ERP, CRM, BI tool, Slack, Gmail, ChatGPT.]
      ],
      [
        #label-strong("9:30 am")
        #v(2pt)
        #text(size: 9.5pt, fill: text-subtle)[Building the weekly vendor-spend report by hand. Exports CSV, pastes into a sheet, pivots, drops it into a Google Doc.]
      ],
      [
        #label-strong("11:15 am")
        #v(2pt)
        #text(size: 9.5pt, fill: text-subtle)[Spots a duplicate vendor charge. Pings AP in Slack. Forwards the email. Opens a ticket. Switches tabs four more times.]
      ],
      [
        #label-strong("3:40 pm")
        #v(2pt)
        #text(size: 9.5pt, fill: text-subtle)[Still hasn't done the actual analysis the CFO asked for this morning.]
      ],
    )
  ],
  // AFTER column
  card(pad: 16pt, fill-color: surface-2, stroke-color: emerald.transparentize(50%))[
    #chip("AFTER", color: rgb("#6ee7b7"), bg-color: emerald.transparentize(80%))
    #v(8pt)
    === Sarah, Ops Lead. Tuesday.
    #v(8pt)
    #stack(spacing: 12pt,
      [
        #label-strong("8:00 am")
        #v(2pt)
        #text(size: 9.5pt, fill: text-primary)[Opens Zivo. One tab. _"What's anomalous in last week's vendor payments?"_]
      ],
      [
        #label-strong("8:02 am")
        #v(2pt)
        #text(size: 9.5pt, fill: text-primary)[Finance Co-pilot returns 3 anomalies across \$284k. NovaPart Ltd flagged duplicate. Workflow drafted to route to AP.]
      ],
      [
        #label-strong("8:05 am")
        #v(2pt)
        #text(size: 9.5pt, fill: text-primary)[Sarah approves. Three approvers notified. Audit log written. Dashboard updates live.]
      ],
      [
        #label-strong("9:00 am")
        #v(2pt)
        #text(size: 9.5pt, fill: text-primary)[Already on the CFO's analysis. Three hours back. Repeated daily.]
      ],
    )
  ],
)

#v(16pt)

#card(fill-color: surface, stroke-color: border-strong, pad: 14pt)[
  #text(size: 9.5pt, fill: text-subtle)[
    The vignette is composite — drawn from the *Atlas Operations* demo storyline
    deployed at #text(font: "JetBrains Mono", fill: accent-light)[zivoworkspace.ai].
    Walk through it live in a 20-minute demo and your own team will recognise
    most of the morning.
  ]
]

#pagebreak()

// =============================================================================
// PAGE 5 — INTRODUCING ZIVO
// =============================================================================
#eyebrow("Introducing Zivo")
#v(10pt)
= Three pillars. #gradient-text[One private workspace.]

#v(8pt)
#text(size: 11pt, fill: text-subtle)[
  Zivo unifies three integrated surfaces — Workspace, Flows, and Insights —
  in a single private tenant with shared identity, audit, and security. One
  product, one workspace, one bill — built on a foundation that won't lock you in.
]

#v(16pt)

// Three pillars
#stack(spacing: 12pt,
  card(pad: 16pt, stroke-color: indigo.transparentize(60%))[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 16pt,
      align(top + center)[
        #box(width: 48pt, height: 48pt, radius: 10pt, fill: indigo.transparentize(80%), stroke: 0.6pt + indigo.transparentize(40%))[
          #align(center + horizon)[#text(size: 22pt, fill: accent-light, weight: 800)[01]]
        ]
      ],
      [
        === Zivo Workspace
        #v(2pt)
        #label-strong("Conversational AI for every team")
        #v(6pt)
        #text(size: 10pt, fill: text-subtle)[
          A private chat workspace where every member of your team gets purpose-built
          agents — Finance Co-pilot, Ops Co-pilot, Customer Insights — that can read
          your documents, query your databases, and call your tools. Multi-model under
          the hood (Claude, GPT, Gemini) so you never lock into a single provider.
        ]
        #v(8pt)
        #grid(columns: (1fr, 1fr, 1fr), column-gutter: 6pt,
          chip("RAG over your docs", color: text-subtle),
          chip("Tool-using agents", color: text-subtle),
          chip("Multi-LLM routing", color: text-subtle),
        )
      ],
    )
  ],

  card(pad: 16pt, stroke-color: cyan.transparentize(60%))[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 16pt,
      align(top + center)[
        #box(width: 48pt, height: 48pt, radius: 10pt, fill: cyan.transparentize(80%), stroke: 0.6pt + cyan.transparentize(40%))[
          #align(center + horizon)[#text(size: 22pt, fill: accent-cyan, weight: 800)[02]]
        ]
      ],
      [
        === Zivo Flows
        #v(2pt)
        #label-strong("Intelligent automation that ties it together")
        #v(6pt)
        #text(size: 10pt, fill: text-subtle)[
          Visual workflows that connect 400+ enterprise apps. Triggered by a
          conversation, a schedule, an inbound webhook, or an agent decision —
          and observable end to end. Where Zapier ends, Zivo begins: branching
          logic, retries, human-in-the-loop approvals, and code escape hatches.
        ]
        #v(8pt)
        #grid(columns: (1fr, 1fr, 1fr), column-gutter: 6pt,
          chip("400+ integrations", color: text-subtle),
          chip("Approval flows", color: text-subtle),
          chip("Webhook triggers", color: text-subtle),
        )
      ],
    )
  ],

  card(pad: 16pt, stroke-color: emerald.transparentize(50%))[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 16pt,
      align(top + center)[
        #box(width: 48pt, height: 48pt, radius: 10pt, fill: emerald.transparentize(80%), stroke: 0.6pt + emerald.transparentize(40%))[
          #align(center + horizon)[#text(size: 22pt, fill: rgb("#6ee7b7"), weight: 800)[03]]
        ]
      ],
      [
        === Zivo Insights
        #v(2pt)
        #label-strong("Live operations intelligence")
        #v(6pt)
        #text(size: 10pt, fill: text-subtle)[
          Code-driven dashboards that read directly from your warehouse and
          render live. Version-controlled, no drag-and-drop chart-builder
          fatigue, embeddable in any internal portal. The same data your agents
          reason over is what your executives see.
        ]
        #v(8pt)
        #grid(columns: (1fr, 1fr, 1fr), column-gutter: 6pt,
          chip("Live SQL", color: text-subtle),
          chip("Version-controlled", color: text-subtle),
          chip("Embeddable", color: text-subtle),
        )
      ],
    )
  ],
)

#pagebreak()

// =============================================================================
// PAGE 6 — ARCHITECTURE
// =============================================================================
#eyebrow("Architecture")
#v(10pt)
= What runs where, #gradient-text[who has access.]

#v(8pt)
#text(size: 10.5pt, fill: text-subtle)[
  Zivo is delivered as a private tenant — your own isolated stack, on
  infrastructure you choose (Hetzner today, Azure or your own cloud on
  request). Your data never crosses tenant boundaries. Your LLM provider keys
  are yours. Your audit log is yours.
]

#v(18pt)

// Architecture diagram — three columns: Inputs | Zivo | Outputs
#card(pad: 18pt, fill-color: surface-2, stroke-color: border-strong)[
  #grid(
    columns: (1fr, auto, 1.4fr, auto, 1fr),
    column-gutter: 8pt,
    align: center + horizon,

    // INPUTS
    [
      #label-strong("Inputs")
      #v(8pt)
      #stack(spacing: 6pt,
        card(pad: 8pt, fill-color: surface)[#text(size: 8.5pt)[Documents · Wikis]],
        card(pad: 8pt, fill-color: surface)[#text(size: 8.5pt)[Postgres · Snowflake · BigQuery]],
        card(pad: 8pt, fill-color: surface)[#text(size: 8.5pt)[Slack · Email · CRM · ERP]],
        card(pad: 8pt, fill-color: surface)[#text(size: 8.5pt)[Your team]],
      )
    ],

    // arrow
    [
      #v(20pt)
      #text(size: 16pt, fill: indigo)[#sym.arrow.r]
    ],

    // ZIVO core
    card(pad: 14pt, fill-color: surface, stroke-color: indigo.transparentize(40%))[
      #label-strong("Zivo · Your private tenant")
      #v(8pt)
      #stack(spacing: 6pt,
        card(pad: 8pt, fill-color: surface-2, stroke-color: indigo.transparentize(60%))[#text(size: 8.5pt, weight: 600)[Zivo Workspace · chat]],
        card(pad: 8pt, fill-color: surface-2, stroke-color: cyan.transparentize(60%))[#text(size: 8.5pt, weight: 600)[Zivo Flows · automation]],
        card(pad: 8pt, fill-color: surface-2, stroke-color: emerald.transparentize(60%))[#text(size: 8.5pt, weight: 600)[Zivo Insights · dashboards]],
        card(pad: 8pt, fill-color: surface-2)[#text(size: 8pt, fill: text-subtle)[Zivo Router · Connect · SSO · Audit]],
      )
    ],

    // arrow
    [
      #v(20pt)
      #text(size: 16pt, fill: cyan)[#sym.arrow.r]
    ],

    // OUTPUTS
    [
      #label-strong("Outputs")
      #v(8pt)
      #stack(spacing: 6pt,
        card(pad: 8pt, fill-color: surface)[#text(size: 8.5pt)[Answers in chat]],
        card(pad: 8pt, fill-color: surface)[#text(size: 8.5pt)[Workflow runs]],
        card(pad: 8pt, fill-color: surface)[#text(size: 8.5pt)[Live dashboards]],
        card(pad: 8pt, fill-color: surface)[#text(size: 8.5pt)[Audit log · Reports]],
      )
    ],
  )

  #v(16pt)
  #grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 8pt,
    chip("Private by default", color: accent-light),
    chip("SSO + SAML ready", color: accent-cyan),
    chip("Bring your own keys", color: rgb("#6ee7b7")),
    chip("Zero vendor lock-in", color: text-subtle),
  )
]

#v(16pt)

#grid(columns: (1fr, 1fr), column-gutter: 14pt,
  card(pad: 14pt)[
    === Deployment surface
    #v(4pt)
    #text(size: 9.5pt, fill: text-subtle)[
      Each customer gets a dedicated VM (or Kubernetes namespace, or on-prem
      bundle) running the full Zivo platform behind a single reverse-proxy with
      automatic TLS. One subdomain per tenant: `acme.zivoworkspace.ai`. Your
      data, your compute, your perimeter.
    ]
  ],
  card(pad: 14pt)[
    === Identity and access
    #v(4pt)
    #text(size: 9.5pt, fill: text-subtle)[
      SSO via Google Workspace, Microsoft Entra, or any OIDC/SAML provider.
      Role-based access on every surface (chat, workflows, dashboards). Audit
      trail captures every prompt, every tool call, every workflow run — exportable
      to your SIEM.
    ]
  ],
)

#pagebreak()

// =============================================================================
// PAGE 7-8 — DEMO CASE STUDY: ATLAS OPERATIONS
// =============================================================================
#eyebrow("Demo Case Study")
#v(10pt)
= Atlas Operations: #gradient-text[a workspace built in two weeks.]

#v(8pt)
#text(size: 10.5pt, fill: text-subtle)[
  Atlas is the demo storyline deployed at #text(font: "JetBrains Mono", fill: accent-light)[zivoworkspace.ai] —
  a fictional 200-person mid-market logistics and distribution operator. The
  scenario, the agents, and the workflows are real and runnable. The numbers
  below are the outcomes a comparable team should expect after Zivo's standard
  4-week implementation.
]

#v(14pt)

// Agents + Workflows side by side
#grid(columns: (1fr, 1fr), column-gutter: 10pt,
  card(pad: 12pt)[
    === Three agents, one workspace
    #v(6pt)
    #stack(spacing: 8pt,
      [
        #chip("FINANCE CO-PILOT", color: accent-light, bg-color: indigo.transparentize(80%))
        #v(3pt)
        #text(size: 8.5pt, fill: text-subtle)[
          Reads the AP ledger, flags anomalies, drafts approval workflows.
          Tools: SQL, vendor-lookup, Slack-notify.
        ]
      ],
      [
        #chip("OPS CO-PILOT", color: accent-cyan, bg-color: cyan.transparentize(80%))
        #v(3pt)
        #text(size: 8.5pt, fill: text-subtle)[
          Answers shipment, route, and SLA questions. Triggers re-routes and carrier notifications.
        ]
      ],
      [
        #chip("CUSTOMER INSIGHTS", color: rgb("#6ee7b7"), bg-color: emerald.transparentize(80%))
        #v(3pt)
        #text(size: 8.5pt, fill: text-subtle)[
          Synthesises feedback across tickets, NPS, and call notes. Surfaces themes weekly.
        ]
      ],
    )
  ],
  card(pad: 12pt)[
    === Three workflows, fully automated
    #v(6pt)
    #stack(spacing: 8pt,
      [
        #text(size: 9pt, weight: 700)[#sym.arrow.r Vendor anomaly review]
        #v(2pt)
        #text(size: 8.5pt, fill: text-subtle)[
          Daily 7am: scan AP, flag duplicates and off-pattern, notify approvers in Slack with one-click approve / deny.
        ]
      ],
      [
        #text(size: 9pt, weight: 700)[#sym.arrow.r Shipment exception triage]
        #v(2pt)
        #text(size: 8.5pt, fill: text-subtle)[
          Real-time: when SLA breach predicted, agent drafts customer comms, suggests re-route, escalates if value > \$50k.
        ]
      ],
      [
        #text(size: 9pt, weight: 700)[#sym.arrow.r Weekly insights digest]
        #v(2pt)
        #text(size: 8.5pt, fill: text-subtle)[
          Monday 8am: synthesise last week's tickets, NPS, calls. Email leadership a 3-paragraph summary with links.
        ]
      ],
    )
  ],
)

#v(10pt)

// Outcomes
#card(pad: 12pt, fill-color: surface-2, stroke-color: border-strong)[
  === The outcomes
  #v(6pt)
  #grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 8pt,
    stat("78%", "faster ad-hoc ops answers", color: indigo),
    stat("4.5h", "saved per ops manager / week", color: cyan),
    stat("$284k", "anomalies caught in 30 days", color: emerald),
    stat("2 wks", "to first production agent", color: amber),
  )
  #v(6pt)
  #text(size: 7.5pt, fill: text-muted)[
    Drawn from the Atlas demo storyline plus pilot data from comparable mid-market customers. Your mileage will depend on integrations, data quality, and which workflows you prioritise.
  ]
]

#pagebreak()

// =============================================================================
// PAGE 8 — DIFFERENTIATION
// =============================================================================
#eyebrow("Why Zivo")
#v(10pt)
= How Zivo compares to #gradient-text[the alternatives.]

#v(12pt)

#let cmp-row(feature, zivo, copilot, build, consultancy) = (
  text(size: 9.5pt, weight: 600, feature),
  align(center)[#text(size: 9.5pt, fill: emerald, weight: 700, zivo)],
  align(center)[#text(size: 9pt, fill: text-subtle, copilot)],
  align(center)[#text(size: 9pt, fill: text-subtle, build)],
  align(center)[#text(size: 9pt, fill: text-subtle, consultancy)],
)

#card(pad: 16pt, fill-color: surface-2, stroke-color: border-strong)[
  #table(
    columns: (1.4fr, 1fr, 1fr, 1fr, 1fr),
    rows: auto,
    stroke: 0.4pt + border,
    inset: 8pt,
    align: left,
    fill: (col, row) => if row == 0 { surface-2 } else { none },

    table.header(
      text(size: 8pt, weight: 700, fill: text-muted, font: "JetBrains Mono")[CAPABILITY],
      align(center)[#text(size: 8pt, weight: 700, fill: accent-light, font: "JetBrains Mono")[ZIVO]],
      align(center)[#text(size: 8pt, weight: 700, fill: text-muted, font: "JetBrains Mono")[CHATGPT ENT.]],
      align(center)[#text(size: 8pt, weight: 700, fill: text-muted, font: "JetBrains Mono")[BUILD IN-HOUSE]],
      align(center)[#text(size: 8pt, weight: 700, fill: text-muted, font: "JetBrains Mono")[BPO / CONSULTANCY]],
    ),

    ..cmp-row("Conversational AI",        "✓ Native",        "✓",          "6+ months",   "—"),
    ..cmp-row("Workflow automation",      "✓ Native",        "—",          "Custom build","Manual labour"),
    ..cmp-row("Live dashboards",          "✓ Native",        "—",          "Custom build","Slide decks"),
    ..cmp-row("Your data, your tenant",   "✓ Always",        "Shared",     "✓",           "—"),
    ..cmp-row("Bring your own LLM keys",  "✓",               "—",          "✓",           "—"),
    ..cmp-row("SSO / SAML / audit log",   "✓",               "✓",          "Build it",    "—"),
    ..cmp-row("Time to value",            "2 weeks",         "1 week",     "6+ months",   "Months"),
    ..cmp-row("Open-source core",         "✓",               "—",          "Optional",    "—"),
    ..cmp-row("Migrate away cleanly",     "✓ Day-one export","Lock-in",    "✓",           "Lock-in"),
  )
]

#v(14pt)

#grid(columns: (1fr, 1fr), column-gutter: 14pt,
  card(pad: 14pt)[
    === The honest compromise
    #v(4pt)
    #text(size: 9.5pt, fill: text-subtle)[
      Zivo isn't the cheapest option. ChatGPT Enterprise is faster to switch on.
      A consultancy will build you something narrower for less. *Zivo wins where
      time-to-value, data sovereignty, and a real workflow layer all matter at once.*
      If only one of those matters, pick the cheapest tool that solves it.
    ]
  ],
  card(pad: 14pt, stroke-color: indigo.transparentize(60%))[
    === The compounding bet
    #v(4pt)
    #text(size: 9.5pt, fill: text-subtle)[
      Every workflow you encode in Zivo is reusable, version-controlled, and
      portable. Build ten over the first quarter and you own a custom operations
      AI nobody else has. Build the same ten in three different SaaS tools and
      you own a vendor management problem.
    ]
  ],
)

#pagebreak()

// =============================================================================
// PAGE 9 — INTEGRATIONS
// =============================================================================
#eyebrow("Integrations")
#v(8pt)
= Your existing stack, #gradient-text[connected.]

#v(6pt)
#text(size: 10pt, fill: text-subtle)[
  Zivo speaks to the tools your team already uses — directly. The grid below is
  the most-requested 48; Zivo Connect supports 400+ apps out of the box and ships
  first-class adapters for any internal system over REST, GraphQL, or webhook.
]

#v(8pt)

#let integrations = json("integrations.json")
#let icon-tile(item) = {
  let safe = item.slug.replace(":", "--")
  block(
    width: 100%,
    height: 50pt,
    radius: 6pt,
    stroke: 0.5pt + border,
    fill: surface,
    inset: 4pt,
  )[
    #align(center + horizon)[
      #stack(spacing: 3pt,
        align(center)[
          #image("assets/integrations/" + safe + ".svg", height: 18pt)
        ],
        align(center)[
          #text(size: 6.5pt, fill: text-subtle, weight: 500, item.name)
        ],
      )
    ]
  ]
}

#grid(
  columns: 6,
  column-gutter: 5pt,
  row-gutter: 5pt,
  ..integrations.map(icon-tile)
)

#v(10pt)

#card(pad: 12pt, fill-color: surface, stroke-color: border-strong)[
  #grid(columns: (auto, 1fr), column-gutter: 12pt,
    align(top + center)[
      #box(width: 26pt, height: 26pt, radius: 6pt, fill: indigo.transparentize(80%), stroke: 0.6pt + indigo.transparentize(40%))[
        #align(center + horizon)[#text(size: 14pt, fill: accent-light, weight: 800)[+]]
      ]
    ],
    [
      === Don't see your tool? It's probably already supported.
      #v(2pt)
      #text(size: 9pt, fill: text-subtle)[
        Anything with a REST API, GraphQL endpoint, webhook, or database can be
        wired up. We'll inventory your stack during discovery week and confirm
        coverage before contract.
      ]
    ],
  )
]

#v(3pt)
#place(bottom + center, dy: 12pt)[
  #text(size: 6.5pt, fill: text-muted)[
    All third-party logos are property of their respective owners. Listed integrations indicate technical compatibility and do not imply partnership or endorsement.
  ]
]

#pagebreak()

// =============================================================================
// PAGE 10 — DEPLOYMENT & PRICING
// =============================================================================
#eyebrow("Deployment & Pricing")
#v(8pt)
= Two paths. #gradient-text[Same product underneath.]

#v(6pt)
#text(size: 10pt, fill: text-subtle)[
  *Managed* is for teams that want Zivo running tomorrow with minimal IT
  involvement. *Enterprise* is for teams that need a dedicated tenant, SSO,
  audit-log export, and a contract their procurement team can sign.
]

#v(10pt)

// Two columns: Managed / Enterprise
#grid(columns: (1fr, 1fr), column-gutter: 14pt,

  // MANAGED
  card(pad: 18pt, stroke-color: cyan.transparentize(60%))[
    #grid(columns: (1fr, auto),
      [#chip("MANAGED", color: accent-cyan, bg-color: cyan.transparentize(80%))],
      [#chip("FROM $399/MO", color: accent-cyan, bg-color: cyan.transparentize(80%))],
    )
    #v(10pt)
    === Managed-Siloed
    #v(2pt)
    #text(size: 9.5pt, fill: text-subtle)[
      Hosted by Zivo. Per-tenant compose stack on shared infrastructure with
      your own Postgres database, your own subdomain, and your own admin.
      Built for SMBs and growing operations teams.
    ]

    #v(12pt)
    #table(
      columns: (1fr, auto, auto),
      stroke: 0.4pt + border,
      inset: 8pt,
      align: (left, right, right),
      table.header(
        text(size: 7.5pt, weight: 700, fill: text-muted, font: "JetBrains Mono")[TIER],
        text(size: 7.5pt, weight: 700, fill: text-muted, font: "JetBrains Mono")[USERS],
        text(size: 7.5pt, weight: 700, fill: text-muted, font: "JetBrains Mono")[/MO],
      ),
      [#text(size: 9pt)[*Starter*]],   [#text(size: 9pt)[Up to 10]], [#text(size: 9pt, weight: 700, fill: accent-cyan)[\$399]],
      [#text(size: 9pt)[*Growth*]],    [#text(size: 9pt)[Up to 25]], [#text(size: 9pt, weight: 700, fill: accent-cyan)[\$799]],
      [#text(size: 9pt)[*Scale*]],     [#text(size: 9pt)[Up to 50]], [#text(size: 9pt, weight: 700, fill: accent-cyan)[\$1,499]],
    )

    #v(8pt)
    #stack(spacing: 4pt,
      check("All three pillars: chat, workflows, dashboards"),
      check("Custom subdomain + email/Slack support"),
      check("SSO (Google, Microsoft) on Scale tier"),
      check("Workflow build credit packs from $1,000"),
    )
  ],

  // ENTERPRISE
  card(pad: 18pt, stroke-color: indigo.transparentize(40%), fill-color: surface-2)[
    #grid(columns: (1fr, auto),
      [#chip("ENTERPRISE", color: accent-light, bg-color: indigo.transparentize(70%))],
      [#chip("FROM $3,000/MO", color: accent-light, bg-color: indigo.transparentize(70%))],
    )
    #v(10pt)
    === Enterprise (dedicated)
    #v(2pt)
    #text(size: 9.5pt, fill: text-subtle)[
      A fully isolated tenant on dedicated infrastructure (Hetzner today, Azure /
      your own cloud on request). Your security review, your audit log, your
      success manager. Built for teams that are putting Zivo in front of
      regulated, paying customers.
    ]

    #v(12pt)
    #table(
      columns: (1fr, auto),
      stroke: 0.4pt + border,
      inset: 8pt,
      align: (left, right),
      table.header(
        text(size: 7.5pt, weight: 700, fill: text-muted, font: "JetBrains Mono")[COMPONENT],
        text(size: 7.5pt, weight: 700, fill: text-muted, font: "JetBrains Mono")[INVESTMENT],
      ),
      [#text(size: 9pt)[*Platform fee*]],            [#text(size: 9pt, weight: 700, fill: accent-light)[from \$3,000/mo]],
      [#text(size: 9pt)[*Setup fee* (one-time)]],    [#text(size: 9pt, weight: 700, fill: accent-light)[from \$5,000]],
      [#text(size: 9pt)[*Workflow / agent build*]],  [#text(size: 9pt, weight: 700, fill: accent-light)[\$200/hr]],
      [#text(size: 9pt)[*Annual prepay discount*]],  [#text(size: 9pt, weight: 700, fill: emerald)[10–15%]],
    )

    #v(8pt)
    #stack(spacing: 4pt,
      check("Dedicated VM per tenant — no shared kernel"),
      check("SAML SSO + RBAC + audit log export to SIEM"),
      check("99.9% uptime SLA + dedicated success manager"),
      check("Quarterly business review with founder"),
    )
  ],
)

#v(10pt)

#card(pad: 12pt, fill-color: surface, stroke-color: indigo.transparentize(60%))[
  #grid(columns: (auto, 1fr), column-gutter: 12pt,
    align(top + center)[
      #box(width: 24pt, height: 24pt, radius: 6pt, fill: indigo.transparentize(80%), stroke: 0.6pt + indigo.transparentize(40%))[
        #align(center + horizon)[#text(size: 13pt, fill: accent-light, weight: 800)[\$]]
      ]
    ],
    [
      *LLM usage is pass-through.* #text(size: 9pt, fill: text-subtle)[
        Zivo connects to your AI providers of choice — OpenAI, Anthropic, Google Gemini, Azure OpenAI, or your own self-hosted models. You bring the API key, you pay the provider directly. No markup, no per-token fees from us, total cost transparency.
      ]
    ],
  )
]

#pagebreak()

// =============================================================================
// PAGE 11 — IMPLEMENTATION TIMELINE
// =============================================================================
#eyebrow("Implementation")
#v(10pt)
= From kickoff to live #gradient-text[in four weeks.]

#v(12pt)

#let week-card(week, title, body, color) = card(pad: 14pt, stroke-color: color.transparentize(50%))[
  #grid(columns: (auto, 1fr), column-gutter: 12pt,
    align(top + center)[
      #box(width: 36pt, height: 36pt, radius: 8pt, fill: color.transparentize(85%), stroke: 0.6pt + color.transparentize(40%))[
        #align(center + horizon)[#text(size: 11pt, fill: color, weight: 800, font: "JetBrains Mono")[#week]]
      ]
    ],
    [
      === #title
      #v(2pt)
      #text(size: 9.5pt, fill: text-subtle, body)
    ]
  )
]

#stack(spacing: 10pt,
  week-card(
    "WK 1",
    "Discovery and provisioning",
    [Stakeholder interviews, integration audit, success metrics agreed.
     Tenant provisioned, SSO configured, baseline data sources connected.
     Internal admin trained.],
    indigo,
  ),
  week-card(
    "WK 2",
    "First agent and workflow",
    [One co-pilot built against your highest-volume use case (typically the
     Finance or Ops Co-pilot pattern). One end-to-end workflow with human
     approval. Pilot users onboarded.],
    cyan,
  ),
  week-card(
    "WK 3",
    "Dashboards and second wave",
    [Two live dashboards wired to your warehouse. Second agent + workflow
     pair built. Audit log validated. SLA testing.],
    rgb("#a78bfa"),
  ),
  week-card(
    "WK 4",
    "Go-live and handover",
    [Full team onboarded. Runbook handed to your admin. Quarterly cadence
     scheduled. First business review booked at week 12.],
    emerald,
  ),
)

#v(14pt)

#card(pad: 14pt, fill-color: surface-2, stroke-color: border-strong)[
  === What we need from #prospect
  #v(6pt)
  #grid(columns: (1fr, 1fr), column-gutter: 16pt, row-gutter: 6pt,
    bullet([An executive sponsor (≤ 1 hour/week)]),
    bullet([An admin contact (≤ 4 hours/week)]),
    bullet([Read-access credentials for 2–3 priority data sources]),
    bullet([SSO provider details (Google / Microsoft / Okta)]),
    bullet([3–5 pilot users for week 2 onwards]),
    bullet([A success metric we'll measure on day 30]),
  )
]

#pagebreak()

// =============================================================================
// PAGE 12 — SECURITY & COMPLIANCE
// =============================================================================
#eyebrow("Security & Compliance")
#v(10pt)
= Built for the people #gradient-text[your security team will ask about.]

#v(8pt)
#text(size: 10.5pt, fill: text-subtle)[
  Zivo's security posture is shaped by the kind of customers we serve —
  operations teams handling commercial data, vendor records, and customer
  PII. Posture below; full security overview and SIG Lite questionnaire
  available on request.
]

#v(14pt)

#grid(columns: (1fr, 1fr), column-gutter: 12pt, row-gutter: 12pt,

  card(pad: 14pt)[
    === Data
    #v(4pt)
    #stack(spacing: 4pt,
      check("Encryption in transit (TLS 1.3) and at rest (AES-256)"),
      check("Per-tenant Postgres — no cross-tenant queries possible"),
      check("Daily encrypted backups, 30-day retention, tested restores"),
      check("Configurable retention on chat history and audit logs"),
    )
  ],

  card(pad: 14pt)[
    === Access
    #v(4pt)
    #stack(spacing: 4pt,
      check("SSO via SAML / OIDC (Google, Microsoft, Okta, Auth0)"),
      check("Role-based access control on chat, workflows, dashboards"),
      check("MFA enforced for admin roles"),
      check("Time-bounded support access via short-lived audit-logged sessions"),
    )
  ],

  card(pad: 14pt)[
    === Operations
    #v(4pt)
    #stack(spacing: 4pt,
      check("Mandatory PR review on all production changes"),
      check("Container vulnerability scanning (Trivy) on every build"),
      check("Centralised logging with 1-year retention"),
      check("Documented incident-response runbook with 24h response SLA"),
    )
  ],

  card(pad: 14pt)[
    === Compliance roadmap
    #v(4pt)
    #stack(spacing: 4pt,
      check("DPA available — GDPR-aligned, sign before kickoff"),
      check("Public sub-processor list, 30-day notice on changes"),
      check([SOC 2 Type 1 — *in flight*, target Q3 2026]),
      check("ISO 27001 — planned for 2027"),
    )
  ],
)

#v(14pt)

#card(pad: 14pt, fill-color: surface-2, stroke-color: border-strong)[
  === Sub-processors (current)
  #v(6pt)
  #grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 8pt, row-gutter: 4pt,
    text(size: 9pt)[*Hetzner Cloud* — primary infrastructure (EU)],
    text(size: 9pt)[*Cloudflare* — DNS, TLS, edge proxy],
    text(size: 9pt)[*Customer-selected AI providers* — pass-through],
    text(size: 9pt)[*Stripe* — billing],
  )
]

#pagebreak()

// =============================================================================
// PAGE 13 — NEXT STEPS
// =============================================================================
#eyebrow("Next Steps")
#v(10pt)
= A 30-day pilot. #gradient-text[Then a clear decision.]

#v(10pt)

#card(pad: 18pt, stroke-color: indigo.transparentize(40%), fill-color: surface-2)[
  #grid(columns: (auto, 1fr), column-gutter: 14pt,
    align(top + center)[
      #box(width: 56pt, height: 56pt, radius: 12pt,
        fill: gradient.linear(indigo, violet, angle: 135deg),
      )[
        #align(center + horizon)[#text(size: 24pt, fill: rgb("#ffffff"), weight: 800)[01]]
      ]
    ],
    [
      === The proposed pilot
      #v(2pt)
      #text(size: 10.5pt, fill: text-subtle)[
        A 30-day, fixed-fee pilot for #prospect. We deliver one production agent,
        one production workflow, and one live dashboard against a metric you choose.
        At day 30 we present the outcomes and you decide: convert to a 12-month
        Enterprise contract at a *15% discount*, extend the pilot, or walk away.
        Setup fee credits 100% against month one if you convert.
      ]
      #v(10pt)
      #grid(columns: (1fr, 1fr, 1fr), column-gutter: 8pt,
        chip("Fixed fee", color: accent-light),
        chip("4-week scope", color: accent-light),
        chip("Convertible", color: emerald),
      )
    ],
  )
]

#v(14pt)

#card(pad: 16pt)[
  === Decision checklist for your team
  #v(6pt)
  #grid(columns: (1fr, 1fr), column-gutter: 18pt, row-gutter: 6pt,
    check("Sponsor identified (operations or finance lead)"),
    check("One pilot use case agreed with stakeholders"),
    check("Security overview reviewed; DPA shared with legal"),
    check("Pilot fee approved through procurement"),
    check("Data-source access credentials lined up"),
    check("Three pilot users committed for week 2"),
  )
]

#v(14pt)

#card(pad: 16pt, fill-color: surface, stroke-color: border-strong)[
  #grid(columns: (1fr, 1fr), column-gutter: 16pt,
    [
      === About Zivo
      #v(2pt)
      #text(size: 9.5pt, fill: text-subtle)[
        Zivo is built and operated by a small, senior team out of Cape Town,
        focused exclusively on operations-team AI. We don't sell consulting hours
        — we sell the platform our customers use to retire them. Our roadmap is
        public, our codebase is built on open source we don't control, and every
        contract includes a clean exit clause.
      ]
    ],
    [
      === Get in touch
      #v(2pt)
      #stack(spacing: 6pt,
        text(size: 9.5pt)[*#prepared-by*],
        text(size: 9.5pt, fill: accent-cyan, font: "JetBrains Mono")[#contact-email],
        text(size: 9.5pt, fill: text-subtle, font: "JetBrains Mono")[zivoworkspace.ai],
      )
      #v(8pt)
      #box(
        fill: gradient.linear(indigo, violet, angle: 135deg),
        radius: 8pt,
        inset: (x: 16pt, y: 10pt),
      )[
        #text(size: 11pt, weight: 700, fill: rgb("#ffffff"))[Book a 30-min walkthrough \u{2192}]
      ]
    ],
  )
]

// =============================================================================
// PAGE 14 — BACK COVER
// =============================================================================
#pagebreak()
#page(
  margin: 0pt,
  header: none,
  footer: none,
  fill: bg,
  background: {
    place(top + left, rect(width: 100%, height: 100%, fill: bg))
    place(center + horizon,
      circle(radius: 360pt, fill: gradient.radial(
        indigo.transparentize(60%), bg.transparentize(100%),
      ))
    )
  },
)[
  #pad(x: 28mm, y: 28mm)[
    #v(50mm)
    #align(center)[
      #image("assets/logo.png", width: 56pt)
      #v(28pt)
      #text(size: 38pt, weight: 800, tracking: -1pt)[
        #gradient-text[Build the workspace.]
      ]
      #v(8pt)
      #text(size: 38pt, weight: 800, tracking: -1pt, fill: text-primary)[
        Retire the busywork.
      ]
      #v(36pt)
      #text(size: 12pt, fill: text-subtle, font: "JetBrains Mono")[zivoworkspace.ai]
      #v(4pt)
      #text(size: 10pt, fill: text-muted, font: "JetBrains Mono")[#contact-email]
      #v(40mm)
      #text(size: 8pt, fill: text-muted, font: "JetBrains Mono")[
        #prepared-date · #version-tag · CONFIDENTIAL — PREPARED FOR #upper(prospect)
      ]
    ]
  ]
]
