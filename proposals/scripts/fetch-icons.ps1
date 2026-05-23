#requires -Version 5.1
<#
.SYNOPSIS
  Downloads brand SVG logos for every entry in integrations.json from Iconify.
  Idempotent — skips files already present.

.NOTES
  Saves to assets/integrations/<slug>.svg where <slug> is the iconify slug
  with ":" replaced by "--" (filesystem safe).

  Run from the proposals/ directory:
    pwsh ./scripts/fetch-icons.ps1
#>

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$jsonFile = Join-Path $root "integrations.json"
$outDir = Join-Path $root "assets\integrations"

if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

$entries = Get-Content $jsonFile -Raw | ConvertFrom-Json

$downloaded = 0
$skipped = 0
$failed = @()

foreach ($e in $entries) {
    $slug = $e.slug
    $safe = $slug -replace ":", "--"
    $target = Join-Path $outDir "$safe.svg"
    if (Test-Path $target) {
        $skipped++
        continue
    }
    $iconPath = $slug -replace ":", "/"
    # Tint monochrome simple-icons SVGs to brand subtle slate so the proposal
    # grid renders uniformly on dark surfaces. logos:* icons ignore this param.
    $url = "https://api.iconify.design/$iconPath.svg?color=%23cbd5e1"
    try {
        Invoke-WebRequest -Uri $url -OutFile $target -UseBasicParsing -ErrorAction Stop
        if ((Get-Item $target).Length -eq 0) {
            Remove-Item $target -Force
            $failed += $slug
            Write-Host "  ! $slug (empty response)" -ForegroundColor Yellow
        } else {
            $downloaded++
            Write-Host "  + $slug" -ForegroundColor Green
        }
    } catch {
        if (Test-Path $target) { Remove-Item $target -Force }
        $failed += $slug
        Write-Host "  ! $slug  ($($_.Exception.Message))" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Done. $downloaded downloaded, $skipped already cached, $($failed.Count) failed."
if ($failed.Count -gt 0) {
    Write-Host "Failed slugs: $($failed -join ', ')" -ForegroundColor Yellow
    Write-Host "Edit integrations.json (try the slug without '-icon', or vice-versa) and rerun."
}
