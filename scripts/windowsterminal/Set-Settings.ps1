$ErrorActionPreference = "Stop"

$RepoPath = "C:\code\DSC-profile\configs\windowsterminal\settings.json"
$LiveDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$LivePath = Join-Path $LiveDir "settings.json"

New-Item -ItemType Directory -Force -Path $LiveDir | Out-Null

$repo = Get-Content -LiteralPath $RepoPath -Raw | ConvertFrom-Json -Depth 32

if (Test-Path -LiteralPath $LivePath) {
    $live = Get-Content -LiteralPath $LivePath -Raw | ConvertFrom-Json -Depth 32
    $knownGuids = @($repo.profiles.list | ForEach-Object { $_.guid })
    $dynamicProfiles = @($live.profiles.list | Where-Object { $_.source -and ($knownGuids -notcontains $_.guid) })
    if ($dynamicProfiles.Count -gt 0) {
        $repo.profiles.list = @($repo.profiles.list) + $dynamicProfiles
    }
}

$repo | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $LivePath -Encoding utf8NoBOM
