<#
.SYNOPSIS
    Registers the local SSH key with GitHub as a commit signing key, so
    commits made on this machine show up as Verified.
#>
$ErrorActionPreference = "Stop"

$KeyPath = Join-Path $env:USERPROFILE ".ssh\id_ed25519.pub"
$Title = "$env:COMPUTERNAME (signing)"

gh auth status *>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "gh is not logged in - starting 'gh auth login', follow the prompts."
    gh auth login
    if ($LASTEXITCODE -ne 0) {
        throw "gh auth login did not complete - re-run this script once you're logged in."
    }
}

if (-not (Test-Path -LiteralPath $KeyPath)) {
    Write-Warning "$KeyPath does not exist - generate the key (ssh-keygen) before registering it with GitHub."
    return
}

$LocalKey = (Get-Content -LiteralPath $KeyPath -Raw).Trim() -split '\s+' | Select-Object -First 2
$LocalKeyBlob = $LocalKey -join ' '

$Registered = gh ssh-key list | Where-Object {
    $Fields = $_ -split "`t"
    $Fields[3] -eq 'signing' -and $Fields[2] -eq $LocalKeyBlob
}

if ($Registered) {
    return
}

gh ssh-key add $KeyPath --type signing --title $Title
Write-Host "Registered $KeyPath with GitHub as a signing key ($Title)"
