$ErrorActionPreference = 'Stop'

$imagePath = "C:\assets\wallpapers\wallpaper.jpg"

Add-Type -Namespace Win32 -Name User32 -MemberDefinition @'
[DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
'@

# SPI_SETDESKWALLPAPER, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE
if (-not [Win32.User32]::SystemParametersInfo(0x0014, 0, $imagePath, 0x01 -bor 0x02)) {
    throw [System.ComponentModel.Win32Exception][System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
}

Write-Host "Desktop wallpaper set to $imagePath"
