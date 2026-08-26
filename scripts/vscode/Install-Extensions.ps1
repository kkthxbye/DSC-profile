$ErrorActionPreference = "Stop"

$ExtensionsFile = Join-Path $PSScriptRoot "..\..\configs\vscode\extensions.txt"
$Extensions = Get-Content -Path $ExtensionsFile | ForEach-Object { $_.Trim() } | Where-Object { $_ }

foreach ($id in $Extensions) {
    code --install-extension $id
}
