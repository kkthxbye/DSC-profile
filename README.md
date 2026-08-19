# DSC-profile

DSC v3

```
dsc config set -f .\DevWorkstation.dsc.yaml
.\Install-Software.ps1
dsc config set -f .\AppConfigs.dsc.yaml
```

`dsc config test -f <file>` runs the same thing read-only, reporting drift without applying.
