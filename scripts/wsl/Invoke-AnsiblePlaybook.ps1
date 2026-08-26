$ErrorActionPreference = "Stop"

$Distro = "Ubuntu-26.04"
$User = "tema"
$RepoDir = "/home/$User/ansible-playbook"

wsl -d $Distro -u $User -- bash -c "export DEBIAN_FRONTEND=noninteractive; sudo apt-get update -qq; sudo apt-get install -y -qq ansible git python3-pip"
wsl -d $Distro -u $User -- bash -c "if [ -d '$RepoDir/.git' ]; then git -C '$RepoDir' pull --ff-only; else git clone https://github.com/kkthxbye/ansible-playbook.git '$RepoDir'; fi"
wsl -d $Distro -u $User -- bash -c "cd '$RepoDir' && ansible-playbook main.yaml"
