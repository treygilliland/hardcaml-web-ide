# Deployment

## Rate Limiting

The API includes built-in rate limiting (10 builds/min per IP). Configure via `RATE_LIMIT_PER_MINUTE` env var.

### Cloudflare Rate Limiting (Recommended)

Add these rules in Cloudflare Dashboard (Security > WAF > Rate limiting rules):

| Rule             | Path       | Rate               | Action    |
| ---------------- | ---------- | ------------------ | --------- |
| Compile endpoint | `/compile` | 60 req/min per IP  | Block     |
| Global fallback  | `/*`       | 300 req/min per IP | Challenge |

This provides defense-in-depth - Cloudflare blocks obvious abuse before it hits Railway.

## Railway Deployment

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
