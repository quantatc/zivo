# Zivo Proposals

Source-of-truth for Zivo customer proposals. The master proposal is built in
[Typst](https://typst.app) — version-controllable, templatable per prospect,
and produces a brand-coherent PDF that matches the dark-mode aesthetic of
`zivoworkspace.ai`.

A separate Statement of Work template (Markdown → Word via pandoc) lives in
`template/sow-template.md` for the legal addendum that lawyers expect to redline.

## What's in here

```
proposals/
  zivo-proposal.typ              Master Typst template (14 pages)
  integrations.json              48 popular corporate integrations (slug + name + category)
  BRANDGUIDE.md                  Colours, fonts, logo, voice — single source of truth
  README.md                      You are here
  assets/
    integrations/                SVG logos fetched from Iconify (gitignored)
  template/
    sow-template.md              Statement of Work — Markdown source for pandoc -> docx
  scripts/
    fetch-icons.{ps1,sh}         Download integration logos from Iconify
    build.{ps1,sh}               Compile the proposal for a given prospect
  out/                           Compiled PDFs (gitignored)
```

## One-time setup

### 1. Install Typst

Windows:
```powershell
winget install Typst.Typst
```

macOS:
```bash
brew install typst
```

Or grab the latest binary from <https://github.com/typst/typst/releases/latest>.
Verify with `typst --version`.

### 2. Install Inter and JetBrains Mono

Both fonts are free and required for the brand to render correctly.

Windows:
```powershell
winget install Inter
# JetBrains Mono — download zip, right-click each .ttf -> Install for all users
# https://www.jetbrains.com/lp/mono/
```

macOS:
```bash
brew install --cask font-inter font-jetbrains-mono
```

If a font is missing Typst will fall back silently to a system sans — the document
will still compile, but tracking and weight will look off.

### 3. Fetch integration logos

```powershell
pwsh ./scripts/fetch-icons.ps1
# or
bash ./scripts/fetch-icons.sh        # requires jq
```

This downloads 48 SVG icons from the Iconify CDN (one-time, idempotent, ~150 KB total).

## Compile a proposal

Generic version:
```powershell
pwsh ./scripts/build.ps1
```

Per-prospect:
```powershell
pwsh ./scripts/build.ps1 -Prospect "Acme Corp" -Industry "logistics"
```

Bash equivalent:
```bash
bash ./scripts/build.sh "Acme Corp" "logistics"
```

The output lands in `out/zivo-proposal-<slug>.pdf`.

### Available variables

All overridable via `--input KEY=VALUE` at the Typst CLI, or via the parameters
on `build.ps1` / `build.sh`.

| Variable      | Default                                | Used in                       |
| ------------- | -------------------------------------- | ----------------------------- |
| `prospect`    | `Your Team`                            | Cover, exec summary, header   |
| `industry`    | `operations`                           | Body copy on a few pages      |
| `prepared_by` | `Antony Chibamu - Founder, Zivo`       | Cover, close                  |
| `email`       | `hello@zivoworkspace.ai`               | Close, back cover             |
| `version`     | `v1.0`                                 | Cover, header                 |
| `date`        | today, formatted "Month DD, YYYY"      | Cover, header, back cover     |

## Updating the integrations grid

1. Edit `integrations.json`.
2. Re-run `fetch-icons.ps1` (or `.sh`) — it skips icons already present.
3. Re-compile — the Typst template reads the JSON at compile time.

The grid is laid out 6 columns × 8 rows (= 48 icons). To change shape, edit the
`columns: 6` line in `zivo-proposal.typ` (search for `// PAGE 9`).

## Statement of Work (Word output)

The legal addendum is intentionally Word-friendly — lawyers redline in Word,
not PDF.

```bash
pandoc template/sow-template.md \
  --from gfm \
  --to docx \
  --reference-doc=template/sow-reference.docx \
  -o out/zivo-sow-acme.docx
```

(Reference doc is optional — pandoc will use a generic Word style if you skip
it. To create one with your branding: `pandoc -o reference.docx --print-default-data-file reference.docx`,
then open in Word, restyle, save back.)

## Brand fidelity checklist

Before sending a proposal, eyeball:

- [ ] Cover is full-bleed dark, no white margins
- [ ] All headings render in Inter (700/800 weight)
- [ ] Code chips render in JetBrains Mono
- [ ] Integrations grid renders all 48 logos at consistent tint
- [ ] Header / footer page numbers appear on every page except 1 and 14
- [ ] Prospect name appears correctly on cover, exec summary, pilot, back cover

If any item is off, fix the Typst — never edit the PDF.
