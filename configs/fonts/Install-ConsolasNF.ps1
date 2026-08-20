$fontUrls = @(
    'https://raw.githubusercontent.com/ongyx/consolas-nf/master/ConsolasNerdFontMono-Regular.ttf'
    'https://raw.githubusercontent.com/ongyx/consolas-nf/master/ConsolasNerdFontMono-Bold.ttf'
    'https://raw.githubusercontent.com/ongyx/consolas-nf/master/ConsolasNerdFontMono-Italic.ttf'
    'https://raw.githubusercontent.com/ongyx/consolas-nf/master/ConsolasNerdFontMono-BoldItalic.ttf'
)

$destDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$pending = $fontUrls | Where-Object { -not (Test-Path (Join-Path $destDir (Split-Path $_ -Leaf))) }

if (-not $pending) {
    Write-Host "Consolas NF already installed."
    return
}

$tempDir = Join-Path $env:TEMP "consolas-nf-$(Get-Random)"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

try {
    # The Fonts shell folder's CopyHere verb installs per-user (no admin) on
    # Windows 10 1809+ and writes the HKCU font registry entry for us.
    $fontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)

    foreach ($url in $pending) {
        $fileName = Split-Path $url -Leaf
        $dest = Join-Path $tempDir $fileName
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        $fontsFolder.CopyHere($dest)
    }

    Write-Host "Installed Consolas NF ($($pending.Count) file(s))."
} finally {
    Start-Sleep -Seconds 2
    Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
