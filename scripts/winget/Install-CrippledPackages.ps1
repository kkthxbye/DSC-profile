$ErrorActionPreference = "Stop"

@(
    @{Id = "mitmproxy.mitmproxy"; Args = @("--ignore-security-hash")}
    @{Id = "Microsoft.Sysinternals.Suite"; Args = @("--ignore-security-hash")}
    @{Id = "Microsoft.PowerShell"; Args = @("--installer-type", "wix", "--scope", "machine", "--custom", "ADD_PATH=1")}
) | ForEach-Object {
    winget install --id $_.Id --source winget --silent --disable-interactivity `
        --accept-package-agreements --accept-source-agreements @($_.Args)
}
