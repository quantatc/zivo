#requires -Version 5.1
<#
.SYNOPSIS
  Compile the Zivo proposal for a specific prospect.

.PARAMETER Prospect
  Display name of the prospect (e.g. "Acme Corp"). Defaults to "generic".

.PARAMETER Industry
  One-word industry descriptor used in body copy (e.g. "logistics", "fintech").
  Defaults to "operations".

.PARAMETER PreparedBy
  Author line on cover and contact block.

.PARAMETER Email
  Contact email shown on the close + back cover.

.PARAMETER Version
  Version tag shown in header / cover (e.g. "v1.0", "v1.2-draft").

.PARAMETER OutFile
  Override the output file path. Defaults to out/zivo-proposal-<slug>.pdf.

.EXAMPLE
  pwsh ./scripts/build.ps1
  pwsh ./scripts/build.ps1 -Prospect "Acme Corp" -Industry "logistics"
#>
param(
    [string]$Prospect    = "generic",
    [string]$Industry    = "operations",
    [string]$PreparedBy  = "Antony Chibamu - Founder, Zivo",
    [string]$Email       = "hello@zivoworkspace.ai",
    [string]$Version     = "v1.0",
    [string]$OutFile     = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not (Get-Command typst -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: typst is not on PATH." -ForegroundColor Red
    Write-Host "Install with:  winget install Typst.Typst"
    Write-Host "or download:   https://github.com/typst/typst/releases/latest"
    exit 1
}

# Slugify prospect for filename: lowercase, alnum + hyphen
$slug = ($Prospect.ToLower() -replace "[^a-z0-9]+", "-").Trim("-")
if (-not $slug) { $slug = "generic" }

if (-not $OutFile) {
    $OutFile = "out/zivo-proposal-$slug.pdf"
}

$outDir = Split-Path -Parent $OutFile
if ($outDir -and -not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

# Make sure icons are present before compiling
$iconCount = (Get-ChildItem -Path "assets/integrations" -Filter "*.svg" -ErrorAction SilentlyContinue).Count
if ($iconCount -lt 40) {
    Write-Host "Integration icons missing — running fetch-icons.ps1 first..." -ForegroundColor Yellow
    & "$PSScriptRoot/fetch-icons.ps1"
}

# Make sure fonts are present
$fontCount = (Get-ChildItem -Path "fonts" -Filter "*.ttf" -ErrorAction SilentlyContinue).Count
if ($fontCount -lt 4) {
    Write-Host "Brand fonts missing — running fetch-fonts.ps1 first..." -ForegroundColor Yellow
    & "$PSScriptRoot/fetch-fonts.ps1"
}

$today = (Get-Date).ToString("MMMM dd, yyyy")

Write-Host "Compiling proposal for '$Prospect' -> $OutFile"

typst compile `
  --font-path fonts `
  --input "prospect=$Prospect" `
  --input "industry=$Industry" `
  --input "prepared_by=$PreparedBy" `
  --input "email=$Email" `
  --input "version=$Version" `
  --input "date=$today" `
  zivo-proposal.typ `
  $OutFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "Done. Open $OutFile" -ForegroundColor Green
} else {
    Write-Host "Compile failed." -ForegroundColor Red
    exit $LASTEXITCODE
}
