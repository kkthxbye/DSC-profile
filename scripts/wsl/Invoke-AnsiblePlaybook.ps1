$ErrorActionPreference = "Stop"
$env:WSL_UTF8 = "1"

$User = "tema"
$RepoDir = "/home/$User/ansible-playbook"

wsl --user $User -- bash -c "export DEBIAN_FRONTEND=noninteractive; sudo apt-get update --quiet=2; sudo apt-get install --yes --quiet=2 ansible git python3-pip"
wsl --user $User -- bash -c "if [ -d '$RepoDir/.git' ]; then git -C '$RepoDir' pull --ff-only; else git clone https://github.com/kkthxbye/ansible-playbook.git '$RepoDir'; fi"
wsl --user $User -- bash -c "cd '$RepoDir' && ansible-playbook main.yaml"
