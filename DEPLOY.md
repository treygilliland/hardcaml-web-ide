# Railway Deployment

Railway has build timeouts, so we use a pre-built base image on GitHub Container Registry.

## Build Base Image (GitHub Actions)

Push to `main` or manually trigger: GitHub → Actions → "Build Base Image" → Run workflow

Triggers automatically when these change:

- `Dockerfile.base`
- `api/pyproject.toml` or `api/uv.lock`
- `hardcaml/build-cache/**`

## Make Package Public

After first build:

1. GitHub → Your profile → Packages → `hardcaml-base`
2. Package settings → Change visibility → Public

## Deploy

```bash
railway up
```

Build time: ~2-5 min (vs 20+ min without base image).

## Alternative: Build Locally

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
make build-base-local   # Local arch only
make build-base         # Multi-platform + push
```

NOTE: Railway only supports amd64 so you need to build the image for that.
