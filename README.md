# DSC-profile

DSC v3

```
dsc config set -f .\Software.winget.dsc.yaml
dsc config set -f .\DevWorkstation.dsc.yaml
dsc config set -f .\AppConfigs.dsc.yaml
```

`dsc config test -f <file>` runs the same thing read-only, reporting drift without applying.

All resources are machine-agnostic — the same files run unmodified on any machine.
