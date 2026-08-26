$profilesIni = "$env:APPDATA\Thunderbird\profiles.ini"
if (-not (Test-Path $profilesIni)) {
    Write-Warning "Thunderbird profiles.ini not found; launch Thunderbird once to create a profile, then re-run this configuration."
    return
}

$sections = (Get-Content $profilesIni -Raw) -split '(?=\[)'

# Collect every profile path referenced anywhere in profiles.ini - by
# [ProfileN] entries and by [InstallXXXX] Default= entries alike - and
# de-duplicate, since an Install section and a Profile section can both
# point at the same directory.
$profilePaths = New-Object System.Collections.Generic.List[string]
foreach ($section in $sections) {
    if (($section -match '^\[Profile\d+\]' -or $section -match '^\[Install[0-9A-Fa-f]+\]') -and $section -match '(?:^|\n)Path=(.+)') {
        $profilePaths.Add($Matches[1].Trim())
    }
    if ($section -match '^\[Install[0-9A-Fa-f]+\]' -and $section -match 'Default=(.+)') {
        $profilePaths.Add($Matches[1].Trim())
    }
}
$profilePaths = $profilePaths | Select-Object -Unique
if (-not $profilePaths) {
    Write-Warning "Could not determine any Thunderbird profile paths from profiles.ini."
    return
}

$tempDir = Join-Path $env:TEMP "fluentbird-$(Get-Random)"
git clone --depth 1 --quiet https://github.com/Deathbyteacup/fluentbird.git $tempDir 2>$null
if (-not (Test-Path $tempDir)) {
    Write-Warning "Failed to fetch FluentBird from GitHub."
    return
}

try {
    foreach ($profilePath in $profilePaths) {
        $profileDir = Join-Path "$env:APPDATA\Thunderbird" $profilePath
        if (-not (Test-Path $profileDir)) {
            Write-Warning "Profile directory not found, skipping: $profileDir"
            continue
        }

        $chromeDir = Join-Path $profileDir "chrome"
        New-Item -ItemType Directory -Force -Path $chromeDir | Out-Null
        Copy-Item -LiteralPath (Join-Path $tempDir "userChrome.css") -Destination $chromeDir -Force
        Copy-Item -LiteralPath (Join-Path $tempDir "custom.css") -Destination $chromeDir -Force
        Copy-Item -LiteralPath (Join-Path $tempDir "Icons") -Destination $chromeDir -Recurse -Force
        Copy-Item -LiteralPath (Join-Path $tempDir "Titlebar_Icons") -Destination $chromeDir -Recurse -Force

        $userJs = Join-Path $profileDir "user.js"
        $prefs = @(
            'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
            'user_pref("widget.windows.mica", true);'
            'user_pref("widget.windows.mica.popups", 2);'
        )
        $existing = if (Test-Path $userJs) { Get-Content $userJs } else { @() }
        $existing = $existing | Where-Object { $_ -notmatch 'toolkit\.legacyUserProfileCustomizations\.stylesheets|widget\.windows\.mica' }
        ($existing + $prefs) | Set-Content -LiteralPath $userJs -Encoding utf8

        Write-Host "FluentBird installed for profile: $profilePath"
    }
}
finally {
    Remove-Item -LiteralPath $tempDir -Recurse -Force
}

Write-Host "Restart Thunderbird and set Appearance theme to 'System theme - auto' if it isn't already."
