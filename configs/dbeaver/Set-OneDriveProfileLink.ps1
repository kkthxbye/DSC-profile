<#
.SYNOPSIS
    Moves DBeaver's profile directory under OneDrive and replaces it with a
    junction, so the workspace/connections/credentials roam between machines
    the same way they do on this one.
#>
$ErrorActionPreference = "Stop"

$LinkPath = Join-Path $env:APPDATA "DBeaverData"
$TargetPath = Join-Path $env:USERPROFILE "OneDrive\Profiles\DBeaverData"

if (Get-Process -Name "dbeaver" -ErrorAction SilentlyContinue) {
    Write-Warning "DBeaver is running - close it and re-run this script to link its profile to OneDrive."
    return
}

$existing = Get-Item -LiteralPath $LinkPath -Force -ErrorAction SilentlyContinue
if ($existing) {
    if ($existing.LinkType -eq "Junction") {
        if ($existing.Target -contains $TargetPath) {
            return
        }
        throw "$LinkPath is already a junction, but points to $($existing.Target) instead of $TargetPath."
    }

    if (Test-Path -LiteralPath $TargetPath) {
        throw "$TargetPath already exists and $LinkPath is a real folder - resolve manually before linking."
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $TargetPath) | Out-Null
    Move-Item -LiteralPath $LinkPath -Destination $TargetPath
}
else {
    New-Item -ItemType Directory -Force -Path $TargetPath | Out-Null
}

New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath | Out-Null
Write-Host "Linked $LinkPath -> $TargetPath"
