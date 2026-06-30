# Run from inside the extracted AdaptiveAI folder (right-click -> Run with PowerShell)
$ErrorActionPreference = "Stop"

$modName = "AdaptiveAI"
$source = $PSScriptRoot
$target = Join-Path $env:USERPROFILE "Games\Age of Empires 2 DE\mods\local\$modName"

if (-not (Test-Path (Join-Path $source "info.json"))) {
    Write-Host "ERROR: Run this script from inside the extracted AdaptiveAI folder."
    exit 1
}

New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
if (Test-Path $target) { Remove-Item $target -Recurse -Force }
Copy-Item -Path $source -Destination $target -Recurse -Force

$patchScript = Join-Path $source "patch-promisory-debug.ps1"
if (Test-Path $patchScript) {
    & $patchScript
}

Write-Host ""
Write-Host "AdaptiveAI installed to:"
Write-Host "  $target"
Write-Host ""
Write-Host "Next steps in Age of Empires II DE:"
Write-Host "  1. Mod Manager -> Local -> AdaptiveAI -> Enable"
Write-Host "  2. Single Player -> Load Scenario -> AdaptiveAI 1v1 Test"
Write-Host "  3. Play — AI adapts silently to your opening"
Write-Host ""