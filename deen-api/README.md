# deen-buddy API

Islamic Q&A API with auto-deployment and dialogue logging.

## Features

- **REST API** - HTTP endpoints for Islamic Q&A
- **Auto-deployment** - Pulls updates from git every 15 minutes
- **Dialogue logging** - All conversations saved locally (not in git)
- **Rate limiting** - Protection against abuse
- **SSL/HTTPS** - Secure communication
- **PM2 process management** - Auto-restart on crashes

## Project Structure

```
server.js           - Express API server
myDeen.js          - Core LLM logic
simple-chat.js     - CLI chat interface
ecosystem.config.js - PM2 configuration
auto-deploy.sh     - Auto-deployment script
setup-cron.sh      - Cron setup script
vps-setup.sh       - VPS automated setup
nginx.conf         - Nginx configuration
logs/              - Dialogue logs (git-ignored)
```

## Local Development

### Install Dependencies
```bash
npm install
```

### Set Up Environment
```bash
cp .env.example .env
# Edit .env with your credentials
```

### Run API Server
```bash
npm start
```

### Test CLI Chat
```bash
npm run chat
```

## API Endpoints

### Health Check
```bash
GET /health
```

### Ask Question
```bash
POST /api/ask
Content-Type: application/json

{
  "question": "What is Islam?"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "answer": "Warm answer with citations...",
    "citations": [...]
  },
  "metadata": {
    "processingTime": 1234
  }
}
```

## VPS Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete deployment guide.

### Quick Deploy on Hetzner VPS (3 Commands)

```bash
# SSH into your VPS
ssh root@your-vps-ip

# Clone repo and run setup
git clone https://github.com/Ardaolmez/deen-buddy.git
cd deen-buddy/deen-api && bash vps-setup-ip.sh
```

That's it! The script handles:
- Installing Node.js, PM2, Nginx
- Installing dependencies
- Setting up your .env file
- Configuring auto-deployment
- Starting the API

**For SSL/HTTPS:** Use `vps-setup.sh` instead and provide a domain name

### Auto-Deployment

Once deployed, the API automatically:
- Checks for git updates every 15 minutes
- Pulls latest changes if available
- Installs new dependencies if needed
- Restarts the API with zero downtime

Logs: `logs/auto-deploy.log`

### Dialogue Logging

All conversations are logged to:
```
logs/dialogues-YYYY-MM-DD.jsonl
```

Format:
```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "question": "...",
  "response": {...},
  "metadata": {
    "ip": "...",
    "userAgent": "...",
    "processingTime": 1234
  }
}
```

**Note:** Logs are automatically excluded from git.

## Environment Variables

```env
ANTHROPIC_BASE_URL=https://your-api-url.com
ANTHROPIC_AUTH_TOKEN=your-api-token
PORT=3000
NODE_ENV=production
```

## Useful Commands

### PM2
```bash
pm2 status              # Check status
pm2 logs deen-api       # View logs
pm2 restart deen-api    # Restart
```

### View Logs
```bash
tail -f logs/dialogues-*.jsonl
tail -f logs/auto-deploy.log
```

### Manual Deploy
```bash
cd /root/deen-buddy
./auto-deploy.sh
```

## Security

- HTTPS with auto-renewing SSL certificates
- Rate limiting (100 req/15min per IP)
- Security headers (Helmet.js)
- Firewall configured (UFW)
- Environment variables for secrets

## Support

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed documentation and troubleshooting.
