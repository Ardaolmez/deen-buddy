# Deploying to Cloudflare Workers

This guide shows how to deploy the deen-api to Cloudflare Workers.

## Why Cloudflare Workers?

- **Free tier**: 100,000 requests/day
- **Zero maintenance**: No servers to manage
- **Global edge network**: Fast responses worldwide
- **Auto-scaling**: Handles traffic spikes automatically
- **No cold starts**: Unlike traditional serverless

## Prerequisites

1. [Cloudflare account](https://dash.cloudflare.com/sign-up) (free)
2. Node.js installed

## Deployment Steps

### 1. Install Wrangler CLI

```bash
npm install -g wrangler
```

### 2. Login to Cloudflare

```bash
wrangler login
```

This will open your browser to authenticate.

### 3. Set Environment Variables

Set your API credentials as secrets (never committed to git):

```bash
# Set your Anthropic API token
wrangler secret put ANTHROPIC_AUTH_TOKEN
# When prompted, paste your token

# Set your API base URL
wrangler secret put ANTHROPIC_BASE_URL
# When prompted, paste your base URL (e.g., https://api.anthropic.com)
```

### 4. Deploy to Cloudflare

```bash
cd deen-api
wrangler deploy
```

That's it! Your API is now live on Cloudflare's global network.

## Your API Endpoints

After deployment, you'll get a URL like:
```
https://deen-api.your-subdomain.workers.dev
```

**Endpoints:**
- `GET /health` - Health check
- `POST /api/ask` - Ask a question

## Testing Your Deployed API

### Health Check
```bash
curl https://deen-api.your-subdomain.workers.dev/health
```

### Ask a Question
```bash
curl -X POST https://deen-api.your-subdomain.workers.dev/api/ask \
  -H 'Content-Type: application/json' \
  -d '{"question":"What is Islam?"}'
```

## Custom Domain (Optional)

To use your own domain:

1. Go to Cloudflare Dashboard → Workers & Pages → deen-api
2. Click "Settings" → "Triggers"
3. Add a custom domain

## Monitoring & Logs

View logs in real-time:
```bash
wrangler tail
```

View metrics in Cloudflare Dashboard:
- Workers & Pages → deen-api → Metrics

## Updating Your API

Just deploy again:
```bash
wrangler deploy
```

Changes are live instantly with zero downtime.

## Local Development

Test locally before deploying:

```bash
# Create a .dev.vars file with your secrets
cat > .dev.vars << EOF
ANTHROPIC_AUTH_TOKEN=your-token-here
ANTHROPIC_BASE_URL=your-base-url-here
EOF

# Run locally
wrangler dev
```

Then test at `http://localhost:8787`

## Cost

**Free tier includes:**
- 100,000 requests/day
- 10ms CPU time per request
- More than enough for most use cases

**Paid tier ($5/month):**
- 10 million requests/month included
- $0.50 per million additional requests

For a mobile app, you'll likely stay on the free tier.

## Advantages Over VPS

| Feature | VPS | Cloudflare Workers |
|---------|-----|-------------------|
| Cost | $5-10/month fixed | Free (likely) |
| Maintenance | Manual updates | Zero |
| Scaling | Manual | Automatic |
| Global performance | Single region | 200+ locations |
| Uptime guarantee | Your responsibility | 99.99% SLA |
| DDoS protection | Extra cost | Included |
| Cold starts | None | None |

## Migrating from VPS

Once deployed to Cloudflare:

1. Update your mobile app to use the new `.workers.dev` URL
2. Test thoroughly
3. Shut down the VPS (save $5-10/month)

## Support

- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Wrangler CLI Docs](https://developers.cloudflare.com/workers/wrangler/)
- [Community Discord](https://discord.gg/cloudflaredev)

## Troubleshooting

**Error: "Module not found"**
- Make sure `worker.js` exists in the same directory as `wrangler.toml`

**Error: "Unauthorized"**
- Run `wrangler login` again

**API returns errors:**
- Check secrets are set: `wrangler secret list`
- View logs: `wrangler tail`

**Need to update secrets:**
```bash
wrangler secret put ANTHROPIC_AUTH_TOKEN
wrangler secret put ANTHROPIC_BASE_URL
```
