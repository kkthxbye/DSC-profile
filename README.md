# DSC-profile

DSC v3

```pwsh
function Invoke-Step {
  process {
    if ($_ -like '*.ps1') {
      & $_
    } else {
      dsc --trace-level trace --trace-format plaintext config set --file $_
    }
  }
}

# Elevated
'.\DevWorkstation.dsc.yaml',
'.\scripts\winget\Enable-InstallerHashOverride.ps1' | Invoke-Step

# Regular
'.\Software.winget.dsc.yaml',
'.\scripts\winget\Install-CrippledPackages.ps1',
'.\scripts\winget\Repair-PortableSymlinks.ps1',
'.\AppConfigs.dsc.yaml' | Invoke-Step

# Optional
'.\Wsl.dsc.yaml',
'.\VisualStudio.dsc.yaml' | Invoke-Step
```

`dsc config test --file <file>` runs the same thing read-only, reporting drift without applying.

To watch the ansible output:
```pwsh
wsl --distribution Ubuntu --exec tail -f /tmp/ansible-playbook.log
```
