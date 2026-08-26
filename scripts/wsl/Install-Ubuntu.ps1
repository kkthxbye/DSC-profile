$ErrorActionPreference = "Stop"
$env:WSL_UTF8 = "1"

$User = "tema"

$installed = (wsl --list --quiet) -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$Distro = $installed | Where-Object { $_ -like "*Ubuntu*" } | Select-Object -First 1

if (-not $Distro) {
    wsl --install Ubuntu --no-launch
    $Distro = "Ubuntu"
}

$userExists = (wsl --distribution $Distro --user root -- bash -c "id --user $User >/dev/null 2>&1 && echo yes || echo no").Trim()
if ($userExists -ne "yes") {
    wsl --distribution $Distro --user root -- bash -c "adduser --disabled-password --gecos '' $User"
}

wsl --distribution $Distro --user root -- bash -c "usermod --append --groups sudo $User"
wsl --distribution $Distro --user root -- bash -c "printf '%s ALL=(ALL) NOPASSWD:ALL\n' '$User' > /etc/sudoers.d/$User && chmod 0440 /etc/sudoers.d/$User && visudo --check --file=/etc/sudoers.d/$User"
wsl --manage $Distro --set-default-user $User
wsl --set-default $Distro
