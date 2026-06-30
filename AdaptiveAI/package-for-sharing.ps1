# Build a zip your friend can copy into their AoE2 DE local mods folder
$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$staging = Join-Path $projectRoot "dist\AdaptiveAI"
$zipPath = Join-Path $projectRoot "dist\AdaptiveAI-test-pack.zip"

python (Join-Path $projectRoot "create_test_scenario.py")

if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Join-Path $staging "resources\_common\ai") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $staging "resources\_common\scenario") | Out-Null

Copy-Item (Join-Path $projectRoot "info.json") -Destination $staging -Force
Copy-Item (Join-Path $projectRoot "resources\_common\ai\*") -Destination (Join-Path $staging "resources\_common\ai") -Recurse -Force

$scenarioSrc = Join-Path $env:USERPROFILE "Games\Age of Empires 2 DE\76561198311478416\resources\_common\scenario\AdaptiveAI 1v1 Test.aoe2scenario"
if (-not (Test-Path $scenarioSrc)) {
    $scenarioSrc = Join-Path $env:USERPROFILE "Games\Age of Empires 2 DE\resources\_common\scenario\AdaptiveAI 1v1 Test.aoe2scenario"
}
Copy-Item $scenarioSrc -Destination (Join-Path $staging "resources\_common\scenario\AdaptiveAI 1v1 Test.aoe2scenario") -Force

Copy-Item (Join-Path $projectRoot "install-on-friend-pc.ps1") -Destination (Join-Path $staging "install.ps1") -Force
Copy-Item (Join-Path $projectRoot "patch-promisory-debug.ps1") -Destination $staging -Force
Copy-Item (Join-Path $projectRoot "INSTALL.txt") -Destination $staging -Force

if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
New-Item -ItemType Directory -Force -Path (Split-Path $zipPath) | Out-Null
Compress-Archive -Path $staging -DestinationPath $zipPath -Force

Write-Host "Share this file with your friend:"
Write-Host "  $zipPath"
Write-Host ""
Write-Host "Or share the folder:"
Write-Host "  $staging"