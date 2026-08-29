$ErrorActionPreference = "Stop"

$PortablePackages = @{
    "Kubernetes.kubectl" = "kubectl.exe"
}

$linksDir    = "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
$packagesDir = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages"

foreach ($id in $PortablePackages.Keys) {
    $exeName = $PortablePackages[$id]
    $linkPath = Join-Path $linksDir $exeName

    if (Test-Path $linkPath) {
        continue
    }

    $packageDir = Get-ChildItem -Path $packagesDir -Directory -Filter "$id*" | Select-Object -First 1
    if (-not $packageDir) {
        Write-Warning "Package directory for $id not found; skipping symlink repair."
        continue
    }

    $target = Join-Path $packageDir.FullName $exeName
    if (-not (Test-Path $target)) {
        Write-Warning "$target not found; skipping symlink repair for $id."
        continue
    }

    New-Item -ItemType SymbolicLink -Path $linkPath -Target $target | Out-Null
    Write-Host "Repaired portable symlink: $exeName -> $target"
}
