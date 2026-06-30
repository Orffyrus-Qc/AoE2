# Deploy AdaptiveAI mod to AoE2 DE install + local mod mirror
$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $projectRoot "resources\_common"
$gameRoot = "C:\Program Files (x86)\Steam\steamapps\common\AoE2DE\resources\_common"
$dstAi = Join-Path $gameRoot "ai"
$dstDrs = Join-Path $gameRoot "drs\gamedata_x2"
$modRoot = Join-Path $env:USERPROFILE "Games\Age of Empires 2 DE\mods\local\AdaptiveAI"

Copy-Item -Path (Join-Path $src "ai\AdaptiveAI.ai") -Destination $dstAi -Force
Copy-Item -Path (Join-Path $src "ai\AdaptiveAI.per") -Destination $dstAi -Force
Copy-Item -Path (Join-Path $src "ai\AdaptiveExtreme.per2") -Destination $dstAi -Force
if (Test-Path (Join-Path $dstAi "AdaptiveAI")) {
    Remove-Item (Join-Path $dstAi "AdaptiveAI") -Recurse -Force
}
Copy-Item -Path (Join-Path $src "ai\AdaptiveAI") -Destination $dstAi -Recurse -Force
Copy-Item -Path (Join-Path $src "ai\AdaptiveExtreme.per2") -Destination $dstDrs -Force

New-Item -ItemType Directory -Force -Path (Join-Path $modRoot "resources\_common\ai") | Out-Null
Copy-Item -Path (Join-Path $src "ai\*") -Destination (Join-Path $modRoot "resources\_common\ai") -Recurse -Force
Copy-Item -Path (Join-Path $projectRoot "info.json") -Destination $modRoot -Force

python (Join-Path $projectRoot "create_test_scenario.py")
& (Join-Path $projectRoot "patch-promisory-debug.ps1")

Write-Host "AdaptiveAI deployed to:"
Write-Host "  $dstAi"
Write-Host "  $dstDrs"
Write-Host "  $modRoot"