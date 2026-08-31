<#
.SYNOPSIS
    Publishes the local portfolio container through Tailscale Funnel (background mode).

.DESCRIPTION
    Run this ONLY after Tailscale is installed and logged in on the host
    (host-level steps that require explicit user approval). The script:

      1. verifies the `tailscale` CLI exists;
      2. verifies Tailscale is running and logged in;
      3. verifies the local Docker origin (http://127.0.0.1:8080) responds;
      4. enables Funnel in background mode: tailscale funnel --bg <port>;
      5. prints `tailscale funnel status` so the public URL is visible.

    It does NOT install software, open firewall/router ports, or store any
    secrets/auth keys. The stable public URL has the form:
    https://<device>.<tailnet>.ts.net

.PARAMETER LocalPort
    Local origin port forwarded by Compose (default 8080).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\deploy\enable-public-funnel.ps1
#>
[CmdletBinding()]
param(
    [int]$LocalPort = 8080
)

$ErrorActionPreference = 'Stop'

function Fail([string]$Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

Write-Host "==> Checking Tailscale CLI..."
$tsCmd = Get-Command tailscale -ErrorAction SilentlyContinue
if (-not $tsCmd) {
    Fail "tailscale CLI not found on PATH. Install Tailscale first (user-approved host step): https://tailscale.com/download"
}

Write-Host "==> Checking Tailscale login state..."
& tailscale status | Out-Host
if ($LASTEXITCODE -ne 0) {
    Fail "Tailscale is not running or not logged in. Run 'tailscale up' in a terminal and complete browser login first."
}

$originUrl = "http://127.0.0.1:$LocalPort/"
Write-Host "==> Checking local origin $originUrl ..."
try {
    $resp = Invoke-WebRequest -Uri $originUrl -UseBasicParsing -TimeoutSec 10
} catch {
    Fail "Local origin did not respond. Start the container first: docker compose up -d --build"
}
if ($resp.StatusCode -ne 200) {
    Fail "Local origin returned HTTP $($resp.StatusCode), expected 200."
}
Write-Host "    Origin OK (HTTP 200)."

Write-Host "==> Enabling Tailscale Funnel on port $LocalPort (background)..."
& tailscale funnel --bg $LocalPort
if ($LASTEXITCODE -ne 0) {
    Fail "'tailscale funnel' failed. Check that HTTPS certificates are enabled: 'tailscale cert' or funnel prompts will guide you."
}

Write-Host ""
Write-Host "==> Funnel status:"
& tailscale funnel status
Write-Host ""
Write-Host "Public URL is shown above as https://<device>.<tailnet>.ts.net"
Write-Host "To stop publishing later: tailscale funnel off"
