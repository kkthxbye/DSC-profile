# DSC-profile

DSC v3

```pwsh
'.\DevWorkstation.dsc.yaml',
'.\Software.winget.dsc.yaml',
'.\scripts\winget\Enable-InstallerHashOverride.ps1',
'.\scripts\winget\Install-CrippledPackages.ps1',
'.\scripts\winget\Repair-PortableSymlinks.ps1',
'.\AppConfigs.dsc.yaml' | % {
    if ($_ -like '*.ps1') {
      & $_
    } else {
      dsc --trace-level trace --trace-format plaintext config set --file $_
    }
}

# Optional:
dsc --trace-level trace --trace-format plaintext config set --file .\Wsl.dsc.yaml
dsc --trace-level trace --trace-format plaintext config set --file .\VisualStudio.dsc.yaml
```

`dsc config test --file <file>` runs the same thing read-only, reporting drift without applying.

To see the ansible progress:
```pwsh
wsl -d Ubuntu-26.04 --exec tail -f /tmp/ansible-playbook.log
```
