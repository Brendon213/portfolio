<#
.SYNOPSIS
    Copies static site files into a clean dist/ directory for Cloudflare Pages.

.DESCRIPTION
    Idempotent publish step: removes the target directory, then copies only
    index.html, css/, js/, and assets/. Does NOT touch Docker, Git, or any
    credentials.  The output directory is suitable for any static host
    (Cloudflare Pages, GitHub Pages, Netlify, etc.).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\deploy\publish.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Resolve project root (one level up from deploy/).
$Root = Split-Path -Parent $PSScriptRoot
$OutDir = Join-Path $Root 'dist'

Write-Host "==> Clean output directory: $OutDir"
if (Test-Path $OutDir) {
    Remove-Item -Recurse -Force $OutDir
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host "==> Copying site files..."
Copy-Item (Join-Path $Root 'index.html') (Join-Path $OutDir 'index.html')

# css/
Copy-Item -Recurse -Force (Join-Path $Root 'css') (Join-Path $OutDir 'css')

# js/
Copy-Item -Recurse -Force (Join-Path $Root 'js')  (Join-Path $OutDir 'js')

# assets/
Copy-Item -Recurse -Force (Join-Path $Root 'assets') (Join-Path $OutDir 'assets')

# Remove stray .gitkeep files that should not be served.
Get-ChildItem -Path $OutDir -Filter '.gitkeep' -Recurse -File -ErrorAction SilentlyContinue | Remove-Item -Force

Write-Host "==> Published to $OutDir"
Write-Host "    Contents:"
Get-ChildItem -Path $OutDir -Recurse -File | ForEach-Object {
    Write-Host "      $($_.FullName.Substring($OutDir.Length + 1))"
}
