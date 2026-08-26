# DSC-profile

DSC v3

```
dsc --trace-level trace --trace-format plaintext config set --file .\DevWorkstation.dsc.yaml
dsc --trace-level trace --trace-format plaintext config set --file .\Software.winget.dsc.yaml
.\scripts\winget\Enable-InstallerHashOverride.ps1
.\scripts\winget\Install-CrippledPackages.ps1
dsc --trace-level trace --trace-format plaintext config set --file .\AppConfigs.dsc.yaml
```

`dsc config test --file <file>` runs the same thing read-only, reporting drift without applying.
