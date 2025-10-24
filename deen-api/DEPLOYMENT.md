# Deployment Guide - deen-buddy API

Complete guide to deploy your deen-buddy API on Hetzner VPS.

## Prerequisites

1. **Hetzner VPS** with Ubuntu 22.04+
2. **Domain name** pointing to your VPS IP address
3. **Git repository** (GitHub, GitLab, etc.)
4. **API credentials** (ANTHROPIC_BASE_URL and ANTHROPIC_AUTH_TOKEN)

---

## Quick Deploy (Automated)

### 1. Connect to Your VPS
```bash
ssh root@your-vps-ip
```

### 2. Upload Setup Script
From your local machine:
```bash
scp vps-setup.sh root@your-vps-ip:/root/
```

### 3. Run Setup Script
On your VPS:
```bash
cd /root
chmod +x vps-setup.sh
./vps-setup.sh
```

The script will:
- Install Node.js, PM2, Nginx, Certbot
- Clone your repository
- Set up environment variables
- Configure Nginx with SSL
- Start the API with PM2
- Set up auto-deployment (every 15 minutes)
- Configure firewall

---

## Manual Setup (Step by Step)

### 1. Initial Server Setup

```bash
# Update system
apt update && apt upgrade -y

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Install PM2
npm install -g pm2

# Install Nginx
apt install -y nginx

# Install Certbot
apt install -y certbot python3-certbot-nginx

# Install Git
apt install -y git
```

### 2. Clone Repository

```bash
cd /root
git clone YOUR_REPO_URL deen-buddy
cd deen-buddy
```

### 3. Install Dependencies

```bash
npm install
```

### 4. Configure Environment Variables

```bash
nano .env
```

Add the following:
```env
ANTHROPIC_BASE_URL=your-api-base-url
ANTHROPIC_AUTH_TOKEN=your-api-token
PORT=3000
NODE_ENV=production
```

### 5. Configure Nginx

```bash
# Copy nginx config
cp nginx.conf /etc/nginx/sites-available/deen-buddy

# Edit domain name
nano /etc/nginx/sites-available/deen-buddy
# Replace "your-domain.com" with your actual domain

# Create symlink
ln -s /etc/nginx/sites-available/deen-buddy /etc/nginx/sites-enabled/

# Remove default site
rm /etc/nginx/sites-enabled/default

# Test configuration
nginx -t

# Restart Nginx
systemctl restart nginx
systemctl enable nginx
```

### 6. Set Up SSL Certificate

```bash
certbot --nginx -d your-domain.com
```

Follow the prompts to complete SSL setup.

### 7. Start Application with PM2

```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd
```

### 8. Set Up Auto-Deployment

```bash
chmod +x auto-deploy.sh setup-cron.sh
./setup-cron.sh
```

This sets up automatic git pull every 15 minutes.

### 9. Configure Firewall

```bash
ufw enable
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw status
```

---

## Verify Deployment

### Test Health Endpoint
```bash
curl https://your-domain.com/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "uptime": 123.45
}
```

### Test API Endpoint
```bash
curl -X POST https://your-domain.com/api/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "What is Islam?"}'
```

---

## Features

### ✅ Auto-Deployment
- Checks for updates every 15 minutes
- Automatically pulls latest code
- Restarts the app if changes detected
- Logs all deployments to `logs/auto-deploy.log`

### ✅ Dialogue Logging
- All conversations saved to `logs/dialogues-YYYY-MM-DD.jsonl`
- Includes timestamp, question, response, IP, and processing time
- Files are automatically ignored by git

### ✅ Rate Limiting
- 100 requests per 15 minutes per IP (Express level)
- 10 requests per second with burst of 20 (Nginx level)

### ✅ Security
- HTTPS with automatic SSL renewal
- Security headers (Helmet.js)
- Firewall configured (UFW)
- CORS enabled

---

## Useful Commands

### PM2 Commands
```bash
pm2 status                 # Check app status
pm2 logs deen-api          # View real-time logs
pm2 restart deen-api       # Restart app
pm2 stop deen-api          # Stop app
pm2 delete deen-api        # Remove app from PM2
pm2 monit                  # Monitor resources
```

### View Logs
```bash
# Dialogue logs
tail -f /root/deen-buddy/logs/dialogues-*.jsonl

# Auto-deployment logs
tail -f /root/deen-buddy/logs/auto-deploy.log

# PM2 logs
tail -f /root/deen-buddy/logs/pm2-out.log
tail -f /root/deen-buddy/logs/pm2-error.log

# Nginx logs
tail -f /var/log/nginx/deen-api-access.log
tail -f /var/log/nginx/deen-api-error.log
```

### Nginx Commands
```bash
nginx -t                   # Test configuration
systemctl restart nginx    # Restart Nginx
systemctl status nginx     # Check status
```

### SSL Certificate Renewal
```bash
# Certbot auto-renews, but you can test:
certbot renew --dry-run

# Force renewal
certbot renew --force-renewal
```

### Manual Deployment
```bash
cd /root/deen-buddy
git pull
npm install
pm2 restart deen-api
```

---

## Managing Auto-Deployment

### View Cron Jobs
```bash
crontab -l
```

### Temporarily Disable Auto-Deployment
```bash
crontab -l | grep -v "auto-deploy.sh" | crontab -
```

### Re-enable Auto-Deployment
```bash
./setup-cron.sh
```

### Change Deployment Frequency
Edit `setup-cron.sh` and change the `CRON_SCHEDULE` variable:
```bash
CRON_SCHEDULE="*/15 * * * *"  # Every 15 minutes
CRON_SCHEDULE="*/30 * * * *"  # Every 30 minutes
CRON_SCHEDULE="0 * * * *"     # Every hour
```

Then run:
```bash
./setup-cron.sh
```

---

## API Endpoints

### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "uptime": 123.45
}
```

### POST /api/ask
Ask a question to myDeen.

**Request:**
```json
{
  "question": "Why is prayer important in Islam?"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "answer": "Alhamdulillah, what a beautiful question! Prayer is a direct connection with Allah...",
    "citations": [
      {
        "ref": "Quran 2:45",
        "surah": "Al-Baqarah",
        "ayah": 45,
        "text": "full verse text"
      }
    ]
  },
  "metadata": {
    "processingTime": 1234
  }
}
```

---

## Troubleshooting

### App Won't Start
```bash
# Check PM2 logs
pm2 logs deen-api --lines 50

# Check environment variables
cat /root/deen-buddy/.env

# Restart manually
cd /root/deen-buddy
npm install
pm2 restart deen-api
```

### SSL Issues
```bash
# Check certificate status
certbot certificates

# Renew certificate
certbot renew --force-renewal

# Update nginx config
nano /etc/nginx/sites-available/deen-buddy
nginx -t
systemctl restart nginx
```

### Auto-Deployment Not Working
```bash
# Check cron jobs
crontab -l

# Check deployment logs
tail -f /root/deen-buddy/logs/auto-deploy.log

# Run deployment manually
cd /root/deen-buddy
./auto-deploy.sh

# Check git status
cd /root/deen-buddy
git status
git remote -v
```

### Port Already in Use
```bash
# Find process using port 3000
lsof -i :3000

# Kill the process (replace PID)
kill -9 PID

# Restart app
pm2 restart deen-api
```

### High Memory Usage
```bash
# Check PM2 status
pm2 status

# Restart app
pm2 restart deen-api

# Set memory limit in ecosystem.config.js
# Change max_memory_restart: '500M' to desired value
```

---

## Security Best Practices

1. **Keep credentials secret** - Never commit `.env` to git
2. **Regular updates** - Run `apt update && apt upgrade` regularly
3. **Monitor logs** - Check logs for suspicious activity
4. **Backup dialogues** - Regularly backup the `logs/` directory
5. **Use strong SSH keys** - Disable password authentication
6. **Rotate API keys** - Change credentials periodically

---

## Backup Strategy

### Backup Dialogues
```bash
# Copy logs directory
scp -r root@your-vps-ip:/root/deen-buddy/logs ./backups/

# Or use rsync
rsync -avz root@your-vps-ip:/root/deen-buddy/logs/ ./backups/logs/
```

### Automate Backups
Create a backup script on your VPS:
```bash
#!/bin/bash
# backup-dialogues.sh
tar -czf /root/backups/dialogues-$(date +%Y%m%d).tar.gz /root/deen-buddy/logs/
# Keep only last 30 days
find /root/backups/ -name "dialogues-*.tar.gz" -mtime +30 -delete
```

---

## Performance Tuning

### Increase Rate Limits
Edit `server.js`:
```javascript
// Change from 100 to 200 requests per 15 minutes
max: 200,
```

### Add More PM2 Instances
Edit `ecosystem.config.js`:
```javascript
instances: 2,  // Run 2 instances
```

### Optimize Nginx
Add to nginx config:
```nginx
gzip on;
gzip_types application/json;
```

---

## Support

For issues or questions:
1. Check logs first
2. Review this documentation
3. Check GitHub issues
4. Contact maintainer

---

## License

ISC
