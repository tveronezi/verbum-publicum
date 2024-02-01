# verbum publicum

## How to?

Install https://github.com/sagiegurari/cargo-make  and any other dependency you see in the `Makefile.toml` file then...

```bash
```bash
cp .env_sample .env
makers kill && makers start && makers deploy && makers deploy-persistence && makers set-secrets && makers status
```
