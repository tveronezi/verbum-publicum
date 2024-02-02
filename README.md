# verbum publicum

## How to?

Install https://github.com/sagiegurari/cargo-make  and any other dependency you see in the `Makefile.toml` file then...

```bash
```bash
cp .env_sample .env
makers kill && makers start 
makers deploy-cert && makers deploy-persistence && makers set-secrets
makers deploy && makers status
```

Update your `/etc/hosts` file to include `127.0.0.1 intra.localhost`. Now you can open your browser at these locations:
* https://localhost (username: user)
* https://intra.localhost 

The credentials are the ones you defined in the `.env` file.
