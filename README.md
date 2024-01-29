# verbum publicum

## How to?

Install https://github.com/sagiegurari/cargo-make then...

### From existing cluster

```bash
```bash
makers --list-all-steps
makers undeploy-wp && makers deploy-wp && makers status
```

### From scratch

```bash
makers --list-all-steps
makers kill && makers start && makers deploy-wp && makers status
```
