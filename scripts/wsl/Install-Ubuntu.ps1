$ErrorActionPreference = "Stop"

$Distro = "Ubuntu-26.04"
$User = "tema"

$installed = (wsl -l -q) -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
if ($installed -notcontains $Distro) {
    wsl --install $Distro --no-launch
}

$userExists = (wsl -d $Distro -u root -- bash -c "id -u $User >/dev/null 2>&1 && echo yes || echo no").Trim()
if ($userExists -ne "yes") {
    wsl -d $Distro -u root -- bash -c "adduser --disabled-password --gecos '' $User"
}

wsl -d $Distro -u root -- bash -c "usermod -aG sudo $User"
wsl -d $Distro -u root -- bash -c "printf '%s ALL=(ALL) NOPASSWD:ALL\n' '$User' > /etc/sudoers.d/$User && chmod 0440 /etc/sudoers.d/$User && visudo -cf /etc/sudoers.d/$User"
wsl --manage $Distro --set-default-user $User
