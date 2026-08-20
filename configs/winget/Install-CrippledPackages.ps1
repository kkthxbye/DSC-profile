$ErrorActionPreference = "Stop"

$CrippledPackages = @(
    "mitmproxy.mitmproxy"
)

foreach ($id in $CrippledPackages) {
    winget install --id $id --source winget --silent --disable-interactivity `
        --accept-package-agreements --accept-source-agreements --ignore-security-hash
}
