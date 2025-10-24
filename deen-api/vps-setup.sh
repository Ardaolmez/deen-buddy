#!/bin/bash

# VPS Setup Script for deen-buddy API
# Run this script on your fresh Hetzner VPS

set -e  # Exit on error

echo "====================================="
echo "  deen-buddy API - VPS Setup"
echo "====================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
REPO_URL="https://github.com/Ardaolmez/deen-buddy.git"
REPO_DIR="/root/deen-buddy"
API_DIR="$REPO_DIR/deen-api"

echo -e "${YELLOW}Please ensure you have:${NC}"
echo "1. A domain pointing to this server's IP"
echo "2. Git repository URL ready"
echo "3. API credentials (.env file contents)"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Update system
echo -e "\n${GREEN}[1/9] Updating system packages...${NC}"
apt update && apt upgrade -y

# Install Node.js (using NodeSource)
echo -e "\n${GREEN}[2/9] Installing Node.js 20.x...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"

# Install PM2 globally
echo -e "\n${GREEN}[3/9] Installing PM2...${NC}"
npm install -g pm2

# Install Nginx
echo -e "\n${GREEN}[4/9] Installing Nginx...${NC}"
apt install -y nginx

# Install Certbot for SSL
echo -e "\n${GREEN}[5/9] Installing Certbot...${NC}"
apt install -y certbot python3-certbot-nginx

# Install Git
echo -e "\n${GREEN}[6/9] Installing Git...${NC}"
apt install -y git

# Clone repository
echo -e "\n${GREEN}[7/9] Cloning repository...${NC}"
cd /root
if [ -d "$REPO_DIR" ]; then
    echo "Directory exists, pulling latest changes..."
    cd "$REPO_DIR"
    git pull
else
    git clone "$REPO_URL" deen-buddy
    cd "$REPO_DIR"
fi

# Install dependencies
echo -e "\n${GREEN}[8/9] Installing Node.js dependencies...${NC}"
cd "$API_DIR"
npm install

# Set up environment variables
echo -e "\n${GREEN}[9/9] Setting up environment variables...${NC}"
cd "$API_DIR"
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat > .env << EOF
# API Configuration
ANTHROPIC_BASE_URL=your-api-base-url
ANTHROPIC_AUTH_TOKEN=your-api-token
PORT=3000
NODE_ENV=production
EOF
    echo -e "${YELLOW}IMPORTANT: Edit .env file with your actual credentials${NC}"
    echo "Run: nano $API_DIR/.env"
    read -p "Press Enter after you've edited the .env file..."
fi

# Configure Nginx
echo -e "\n${GREEN}Configuring Nginx...${NC}"
read -p "Enter your domain name (e.g., api.example.com): " DOMAIN

# Copy nginx config
cd "$API_DIR"
cp nginx.conf /etc/nginx/sites-available/deen-buddy

# Update domain in nginx config
sed -i "s/your-domain.com/$DOMAIN/g" /etc/nginx/sites-available/deen-buddy

# Create symlink
ln -sf /etc/nginx/sites-available/deen-buddy /etc/nginx/sites-enabled/

# Remove default nginx site
rm -f /etc/nginx/sites-enabled/default

# Test nginx config
nginx -t

# Restart nginx
systemctl restart nginx
systemctl enable nginx

# Start application with PM2
echo -e "\n${GREEN}Starting application with PM2...${NC}"
cd "$API_DIR"
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u root --hp /root

# Set up SSL with Certbot
echo -e "\n${GREEN}Setting up SSL certificate...${NC}"
echo -e "${YELLOW}Note: Ensure your domain DNS is pointing to this server${NC}"
read -p "Set up SSL certificate now? (y/n): " setup_ssl

if [ "$setup_ssl" = "y" ]; then
    certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --register-unsafely-without-email || {
        echo -e "${RED}SSL setup failed. You can run it manually later:${NC}"
        echo "certbot --nginx -d $DOMAIN"
    }
fi

# Set up auto-deploy cron job
echo -e "\n${GREEN}Setting up auto-deployment...${NC}"
bash setup-cron.sh

# Configure firewall
echo -e "\n${GREEN}Configuring firewall...${NC}"
ufw --force enable
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw status

# Create logs directory
mkdir -p logs

echo -e "\n${GREEN}====================================="
echo "  Setup Complete! ✓"
echo "=====================================${NC}"
echo ""
echo "Your API is now running at:"
echo "  https://$DOMAIN/health"
echo "  https://$DOMAIN/api/ask"
echo ""
echo "Useful commands:"
echo "  pm2 status              - Check app status"
echo "  pm2 logs deen-api       - View logs"
echo "  pm2 restart deen-api    - Restart app"
echo "  nginx -t                - Test nginx config"
echo "  systemctl restart nginx - Restart nginx"
echo "  tail -f logs/auto-deploy.log - View deployment logs"
echo ""
echo "Auto-deployment is active (every 15 minutes)"
echo "Dialogues are logged in: $REPO_DIR/logs/"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Test your API: curl https://$DOMAIN/health"
echo "2. Make a test request:"
echo "   curl -X POST https://$DOMAIN/api/ask \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"question\":\"What is Islam?\"}'"
echo ""
