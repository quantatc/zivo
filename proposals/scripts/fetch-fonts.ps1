#requires -Version 5.1
<#
.SYNOPSIS
  Download Inter and JetBrains Mono into proposals/fonts/ so Typst can find
  them via --font-path (no system install needed). Idempotent.

.NOTES
  Run from the proposals/ directory:
    pwsh ./scripts/fetch-fonts.ps1
#>

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$fontsDir = Join-Path $root "fonts"
$tmpDir = Join-Path $env:TEMP "zivo-fonts"

if (-not (Test-Path $fontsDir)) {
    New-Item -ItemType Directory -Path $fontsDir | Out-Null
}
if (-not (Test-Path $tmpDir)) {
    New-Item -ItemType Directory -Path $tmpDir | Out-Null
}

$packs = @(
    @{
        Name    = "Inter"
        Url     = "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
        Marker  = "Inter-Regular.ttf"
        SubPath = "Inter Desktop"
    },
    @{
        Name    = "JetBrains Mono"
        Url     = "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
        Marker  = "JetBrainsMono-Regular.ttf"
        SubPath = "fonts/ttf"
    }
)

foreach ($p in $packs) {
    $marker = Join-Path $fontsDir $p.Marker
    if (Test-Path $marker) {
        Write-Host "  = $($p.Name) already present, skipping." -ForegroundColor DarkGray
        continue
    }

    $zip = Join-Path $tmpDir ("{0}.zip" -f ($p.Name -replace " ", "_"))
    $extracted = Join-Path $tmpDir ($p.Name -replace " ", "_")

    Write-Host "  + Downloading $($p.Name)..." -ForegroundColor Green
    Invoke-WebRequest -Uri $p.Url -OutFile $zip -UseBasicParsing -ErrorAction Stop

    if (Test-Path $extracted) { Remove-Item -Recurse -Force $extracted }
    New-Item -ItemType Directory -Path $extracted | Out-Null
    Expand-Archive -LiteralPath $zip -DestinationPath $extracted -Force

    $candidateDir = Join-Path $extracted $p.SubPath
    if (-not (Test-Path $candidateDir)) {
        # Fallback: search for ttf folder anywhere in the extract.
        $candidate = Get-ChildItem -Path $extracted -Recurse -Include "*.ttf" -File |
            Group-Object Directory | Sort-Object Count -Descending | Select-Object -First 1
        if ($candidate) { $candidateDir = $candidate.Group[0].DirectoryName }
    }

    if (-not (Test-Path $candidateDir)) {
        Write-Host "    ! Could not locate TTF directory in $($p.Name) extract." -ForegroundColor Yellow
        continue
    }

    Get-ChildItem -Path $candidateDir -Filter "*.ttf" -File | ForEach-Object {
        Copy-Item $_.FullName -Destination (Join-Path $fontsDir $_.Name) -Force
    }
    Write-Host "    -> copied $($p.Name) TTFs to fonts/" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done. Pass '--font-path fonts' to typst, or use scripts/build.ps1."
