<#
.SYNOPSIS
    Un-redirects Desktop/Documents/Pictures from OneDrive's Known Folder Move
    back to local paths, keeping any existing files on this PC. Idempotent -
    on a machine where KFM was never enabled, this is a no-op.
#>
$ErrorActionPreference = "Stop"

$Folders = @(
    @{ Name = "Desktop";   RegValue = "Desktop" },
    @{ Name = "Documents"; RegValue = "Personal" },
    @{ Name = "Pictures";  RegValue = "My Pictures" }
)

$OneDriveRoot = (Get-ItemProperty "HKCU:\Software\Microsoft\OneDrive\Accounts\Personal" -ErrorAction SilentlyContinue).UserFolder
if (-not $OneDriveRoot) {
    return
}

$ShellFolders = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
$ShellFoldersLegacy = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"

$oneDriveStopped = $false

foreach ($folder in $Folders) {
    $currentPath = (Get-ItemProperty $ShellFolders -Name $folder.RegValue).($folder.RegValue)
    $oneDrivePath = Join-Path $OneDriveRoot $folder.Name
    $localPath = Join-Path $env:USERPROFILE $folder.Name

    if ($currentPath -ne $oneDrivePath) {
        continue
    }

    if (-not $oneDriveStopped) {
        Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force
        $oneDriveStopped = $true
    }

    try {
        New-Item -ItemType Directory -Force -Path $localPath

        Get-ChildItem -LiteralPath $oneDrivePath -File -Recurse -Force | ForEach-Object {
            $relativePath = $_.FullName.Substring($oneDrivePath.Length).TrimStart('\')
            $destinationFile = Join-Path $localPath $relativePath
            New-Item -ItemType Directory -Force -Path (Split-Path $destinationFile)
            Move-Item -LiteralPath $_.FullName -Destination $destinationFile -Force
        }

        Set-ItemProperty -Path $ShellFolders -Name $folder.RegValue -Value $localPath
        Set-ItemProperty -Path $ShellFoldersLegacy -Name $folder.RegValue -Value $localPath

        Remove-Item -LiteralPath $oneDrivePath -Force -ErrorAction SilentlyContinue

        Write-Host "Un-redirected $($folder.Name): $oneDrivePath -> $localPath (kept on this PC)"
    }
    catch {
        Write-Warning "Failed to un-redirect $($folder.Name): $_"
    }
}

if ($oneDriveStopped) {
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Start-Process "explorer.exe"
    Start-Process (Join-Path $env:LOCALAPPDATA "Microsoft\OneDrive\OneDrive.exe")
}
