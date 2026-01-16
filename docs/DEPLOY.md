# Deployment

## Architecture

The project has two separate deployments:

1. **IDE + Docs** - Combined Astro site deployed to GitHub Pages (static hosting)
2. **API** - FastAPI backend deployed to Railway (API-only, no static files)

The IDE is integrated into the Astro docs site and makes API calls to the Railway backend.

## Setup

1. Copy `.env.example` to `.env`:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set your configuration:
   - `PUBLIC_API_BASE_URL`: API base URL (e.g., `https://hardcaml.tg3.dev`) - used by IDE
   - `VITE_PUBLIC_POSTHOG_KEY`: Your PostHog API key (optional, for analytics)
   - `RATE_LIMIT_PER_MINUTE`: API rate limit (default: 10)
   - `GITHUB_USERNAME`: Only needed if building/pushing your own images (defaults to `treygilliland`)
   - Other values as needed

**Note:** The Docker images are publicly available at `ghcr.io/treygilliland/`, so you can use them directly without building your own.

## Rate Limiting

The API includes built-in rate limiting (10 builds/min per IP). Configure via `RATE_LIMIT_PER_MINUTE` env var.

### Cloudflare Rate Limiting (Recommended)

Add these rules in Cloudflare Dashboard (Security > WAF > Rate limiting rules):

| Rule             | Path       | Rate               | Action    |
| ---------------- | ---------- | ------------------ | --------- |
| Compile endpoint | `/compile` | 60 req/min per IP  | Block     |
| Global fallback  | `/*`       | 300 req/min per IP | Challenge |

This provides defense-in-depth - Cloudflare blocks obvious abuse before it hits Railway.

## IDE + Docs Deployment (GitHub Pages)

The IDE and docs are deployed together as a static site via GitHub Actions.

### Automatic Deployment

The deployment workflow (`.github/workflows/deploy-docs.yml`) automatically:

1. Builds the Astro site (which includes the IDE)
2. Sets `PUBLIC_API_BASE_URL` environment variable (defaults to `https://hardcaml.tg3.dev`)
3. Deploys to GitHub Pages

### Manual Deployment

1. **Set the API base URL** (if different from default):

   - Add `PUBLIC_API_BASE_URL` as a GitHub secret, or
   - Update the workflow to use your API URL

2. **Trigger deployment**:
   - Go to GitHub → Actions → "Deploy Docs to GitHub Pages" → Run workflow
   - Or push to the configured branch (if auto-deploy is enabled)

The IDE will be accessible at `/ide` on your GitHub Pages site.

## API Deployment (Railway)

Railway has build timeouts, so we use pre-built images on GitHub Container Registry.

## Build and Push Images

Images are built via GitHub Actions or manually on an amd64 dev server and pushed to GHCR:

### Using GitHub Actions

> The image build process requires at least 8GB of RAM so you will need to configure that in GHA.

1. Go to GitHub → Actions → "Build and Push Images" → Run workflow
2. The workflow will automatically build and push both images to `ghcr.io/treygilliland/`

**Note:** The workflow uses `github.repository_owner`, so it will work for any fork. If you want to push to your own GHCR, update the workflow or use manual build/push.

### Manual Build and Push (Optional)

If you want to build and push your own images instead of using the public ones:

```bash
# Load environment variables from .env
export $(cat .env | grep -v '^#' | xargs)

# Set your GitHub token (create a Personal Access Token with 'write:packages' permission)
export GITHUB_TOKEN=your_github_token_here

# Login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u ${GITHUB_USERNAME} --password-stdin

# Build and push both images
make push-all

# Or build/push individually
make push-base   # Build and push base image
make push-prod   # Build and push production image
```

**Note:** By default, images are built for `ghcr.io/treygilliland/`. To push to your own GHCR, set `GITHUB_USERNAME` in your `.env` file.

Images are built for `linux/amd64` only (Railway requirement).

## Make Packages Public (If Building Your Own)

If you're building and pushing your own images, after first build, make both packages public:

1. GitHub → Your profile → Packages → `hardcaml-base`
2. Package settings → Change visibility → Public
3. Repeat for `hardcaml-web-ide`

**Note:** The images at `ghcr.io/treygilliland/` are already public and available for use.

## Deploy

1. **Update `railway.json`** with your production image name:

   ```json
   {
     "deploy": {
       "image": "ghcr.io/YOUR-GITHUB-USERNAME/hardcaml-web-ide:latest"
     }
   }
   ```

   Replace `YOUR-GITHUB-USERNAME` with your actual GitHub username.

2. **Deploy to Railway:**
   ```bash
   railway up
   ```

Railway will pull the pre-built image directly from GHCR, skipping the build step entirely.

**Note:** Make sure the `hardcaml-web-ide` package is public on GHCR, or configure Railway with a `DOCKER_AUTH_TOKEN` environment variable (GitHub Personal Access Token with `read:packages` permission).

## Custom Domain Setup

### IDE + Docs (GitHub Pages)

1. **Configure GitHub Pages custom domain:**

   - GitHub → Repository → Settings → Pages
   - Set custom domain (e.g., `hardcaml.tg3.dev`)
   - GitHub will provide DNS instructions

2. **Update DNS:**
   - Add the CNAME record as instructed by GitHub
   - Wait for DNS propagation

### API (Railway)

1. **Add custom domain in Railway:**

   - Railway Dashboard → Service → Settings → Domains
   - Click **Generate Domain** or **Add Custom Domain**
   - Copy the provided CNAME target
   - Use a subdomain like `hardcaml.tg3.dev`

2. **Configure DNS:**

   - Add a CNAME record:
     - Name: `api` (or your subdomain)
     - Target: (paste the Railway CNAME target)
     - Proxy status: Proxied (orange cloud) if using Cloudflare
   - SSL/TLS mode should be set to **Full** (SSL/TLS → Overview → Full)

3. **Update API base URL:**

   - Update `PUBLIC_API_BASE_URL` in GitHub Actions secrets to match your Railway domain
   - Redeploy the docs site

4. **Wait for propagation:**
   - Railway will automatically provision SSL certificates
   - DNS propagation typically takes a few minutes

The IDE will be accessible at your GitHub Pages domain, and it will make API calls to your Railway domain.
