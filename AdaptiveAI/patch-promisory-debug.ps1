# Strip leftover Promisory dev chat lines that spam every tick during play.
$ErrorActionPreference = "Stop"

$initPer = "C:\Program Files (x86)\Steam\steamapps\common\AoE2DE\resources\_common\ai\Promisory\init.per"
if (-not (Test-Path $initPer)) {
    Write-Warning "Promisory init.per not found - skip debug patch: $initPer"
    exit 0
}

$content = Get-Content $initPer -Raw
$patched = $content `
    -replace '\r?\n\t\(chat-to-player my-player-number "Debugging attack-goal => No\."\)\)', ')' `
    -replace '\r?\n\t\(chat-to-player my-player-number "Debugging attack-goal => Yes\."\)\)', ')'

if ($patched -eq $content) {
    Write-Host "Promisory debug chat already patched (or lines moved)."
} else {
    Set-Content -Path $initPer -Value $patched -NoNewline
    Write-Host "Removed Promisory attack-goal debug chat."
}