<#
.SYNOPSIS
    Ensures the KeePass vault lives under OneDrive and is reachable via a
    stable local junction, so the same database is used on every machine.
#>
$ErrorActionPreference = "Stop"

$LinkPath = Join-Path $env:USERPROFILE "KeePass"
$TargetPath = Join-Path $env:USERPROFILE "OneDrive\Profiles\Keepass"

if (Get-Process -Name "KeePassXC" -ErrorAction SilentlyContinue) {
    Write-Warning "KeePassXC is running - close it and re-run this script to link its vault folder to OneDrive."
    return
}

$existing = Get-Item -LiteralPath $LinkPath -Force -ErrorAction SilentlyContinue
if ($existing) {
    if ($existing.LinkType -ne "Junction") {
        throw "$LinkPath already exists and is not a junction - resolve manually before linking."
    }
    if ($existing.Target -contains $TargetPath) {
        return
    }
    throw "$LinkPath is already a junction, but points to $($existing.Target) instead of $TargetPath."
}

New-Item -ItemType Directory -Force -Path $TargetPath
New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath
Write-Host "Linked $LinkPath -> $TargetPath"
