$ErrorActionPreference = "Stop"

winget settings --enable InstallerHashOverride

$CrippledPackages = @(
    "mitmproxy.mitmproxy",
    "Microsoft.Sysinternals.Suite"
)

foreach ($id in $CrippledPackages) {
    winget install --id $id --source winget --silent --disable-interactivity `
        --accept-package-agreements --accept-source-agreements --ignore-security-hash
}
