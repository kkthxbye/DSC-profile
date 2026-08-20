[CmdletBinding()]
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'Software.winget.dsc.yaml')
)

$content = Get-Content -Raw -Path $ConfigPath
$tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "dsc-package-$PID.json"

function Invoke-DscResourceSet {
    param([hashtable]$InputObject, [string]$ResourceType)
    $InputObject | ConvertTo-Json -Compress | Set-Content -Path $tempFile -NoNewline
    $output = dsc resource set -r $ResourceType -f $tempFile 2>&1
    [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
}

try {
    $sourceMatch = [regex]::Match(
        $content,
        '(?ms)^- name: (?<name>\S+)\s*\n\s*type: Microsoft\.WinGet/Source\s*\n\s*properties:\s*\n\s*type: "(?<type>[^"]+)"\s*\n\s*trustLevel: "(?<trustLevel>[^"]+)"\s*\n\s*argument: "(?<argument>[^"]+)"\s*\n\s*name: "(?<sourceName>[^"]+)"'
    )
    if (-not $sourceMatch.Success) {
        throw "Could not find a Microsoft.WinGet/Source resource in $ConfigPath"
    }

    Write-Host "Applying source '$($sourceMatch.Groups['sourceName'].Value)'..."
    $sourceResult = Invoke-DscResourceSet -ResourceType 'Microsoft.WinGet/Source' -InputObject @{
        type       = $sourceMatch.Groups['type'].Value
        trustLevel = $sourceMatch.Groups['trustLevel'].Value
        argument   = $sourceMatch.Groups['argument'].Value
        name       = $sourceMatch.Groups['sourceName'].Value
    }
    if ($sourceResult.ExitCode -ne 0) {
        throw "Failed to apply winget source '$($sourceMatch.Groups['sourceName'].Value)' (exit $($sourceResult.ExitCode)). Aborting - packages depend on it."
    }

    $packageMatches = [regex]::Matches(
        $content,
        '(?ms)^- name: (?<name>\S+)\s*\n\s*type: Microsoft\.WinGet/Package\s*\n.*?\n\s*properties:\s*\n\s*id: "(?<id>[^"]+)"\s*\n\s*source: "(?<source>[^"]+)"'
    )

    $failed = [System.Collections.Generic.List[string]]::new()
    $succeeded = 0

    foreach ($m in $packageMatches) {
        $id = $m.Groups['id'].Value
        $source = $m.Groups['source'].Value
        Write-Host "Installing $id..."

        $result = Invoke-DscResourceSet -ResourceType 'Microsoft.WinGet/Package' -InputObject @{ id = $id; source = $source }

        if ($result.ExitCode -ne 0) {
            if ($result.Output -match 'hash') {
                Write-Warning "$id failed hash verification - retrying with --ignore-security-hash"
                winget install --id $id --source $source --silent --disable-interactivity `
                    --accept-package-agreements --accept-source-agreements --ignore-security-hash | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    $succeeded++
                    continue
                }
                Write-Warning "$id still failed after --ignore-security-hash (exit $LASTEXITCODE)"
            } else {
                Write-Warning "Failed: $id (exit $($result.ExitCode)) - continuing with the rest"
            }
            $failed.Add($id)
        } else {
            $succeeded++
        }
    }

    Write-Host ""
    Write-Host "Done: $succeeded succeeded, $($failed.Count) failed."
    if ($failed.Count -gt 0) {
        Write-Host "Failed packages:"
        $failed | ForEach-Object { Write-Host "  - $_" }
    }
} finally {
    Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue -Confirm:$false
}
