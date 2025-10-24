#!/bin/bash

# VPS Setup Script for deen-buddy API (IP-only, no SSL)
# Optimized for Hetzner VPS at 135.181.197.98

set -e  # Exit on error

echo "====================================="
echo "  deen-buddy API - VPS Setup"
echo "  IP: 135.181.197.98"
echo "====================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
SERVER_IP="135.181.197.98"
REPO_DIR="/root/deen-buddy"

echo -e "${YELLOW}This script will set up deen-buddy API on your Hetzner VPS${NC}"
echo ""
echo "What will be installed:"
echo "  - Node.js 20.x"
echo "  - PM2 (process manager)"
echo "  - Nginx (reverse proxy)"
echo "  - Git"
echo ""
echo "What will be configured:"
echo "  - API running on port 3000"
echo "  - Nginx proxying on port 80"
echo "  - Auto-deployment every 15 minutes"
echo "  - Firewall (SSH, HTTP)"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Update system
echo -e "\n${GREEN}[1/8] Updating system packages...${NC}"
apt update && apt upgrade -y

# Install Node.js (using NodeSource)
echo -e "\n${GREEN}[2/8] Installing Node.js 20.x...${NC}"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"

# Install PM2 globally
echo -e "\n${GREEN}[3/8] Installing PM2...${NC}"
npm install -g pm2

# Install Nginx
echo -e "\n${GREEN}[4/8] Installing Nginx...${NC}"
apt install -y nginx

# Install Git
echo -e "\n${GREEN}[5/8] Installing Git...${NC}"
apt install -y git

# Clone or update repository
echo -e "\n${GREEN}[6/8] Setting up repository...${NC}"
echo -e "${YELLOW}Enter your Git repository URL:${NC}"
echo "Example: https://github.com/yourusername/deen-buddy.git"
read -p "Repository URL: " REPO_URL

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
echo -e "\n${GREEN}[7/8] Installing Node.js dependencies...${NC}"
npm install

# Set up environment variables
echo -e "\n${GREEN}[8/8] Setting up environment variables...${NC}"
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat > .env << 'EOF'
# API Configuration
ANTHROPIC_BASE_URL=your-api-base-url
ANTHROPIC_AUTH_TOKEN=your-api-token
PORT=3000
NODE_ENV=production
EOF
    echo -e "${YELLOW}IMPORTANT: You need to edit .env with your credentials${NC}"
    echo ""
    echo "Press Enter to edit .env now..."
    read
    nano .env
else
    echo ".env file already exists, skipping..."
fi

# Configure Nginx
echo -e "\n${GREEN}Configuring Nginx...${NC}"

# Use IP-only nginx config
cp nginx-ip.conf /etc/nginx/sites-available/deen-buddy

# Create symlink
ln -sf /etc/nginx/sites-available/deen-buddy /etc/nginx/sites-enabled/

# Remove default nginx site
rm -f /etc/nginx/sites-enabled/default

# Test nginx config
echo "Testing Nginx configuration..."
nginx -t

# Restart nginx
systemctl restart nginx
systemctl enable nginx

# Start application with PM2
echo -e "\n${GREEN}Starting application with PM2...${NC}"
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u root --hp /root

# Set up auto-deploy cron job
echo -e "\n${GREEN}Setting up auto-deployment...${NC}"
bash setup-cron.sh

# Configure firewall
echo -e "\n${GREEN}Configuring firewall...${NC}"
ufw --force enable
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw status

# Create logs directory
mkdir -p logs

echo -e "\n${GREEN}====================================="
echo "  Setup Complete! ✓"
echo "=====================================${NC}"
echo ""
echo "Your API is now running at:"
echo "  http://$SERVER_IP/health"
echo "  http://$SERVER_IP/api/ask"
echo ""
echo "Test your API:"
echo "  curl http://$SERVER_IP/health"
echo ""
echo "Make a test request:"
echo "  curl -X POST http://$SERVER_IP/api/ask \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"question\":\"What is Islam?\"}'"
echo ""
echo "Useful commands:"
echo "  pm2 status              - Check app status"
echo "  pm2 logs deen-api       - View logs"
echo "  pm2 restart deen-api    - Restart app"
echo "  nginx -t                - Test nginx config"
echo "  systemctl restart nginx - Restart nginx"
echo "  tail -f logs/auto-deploy.log - View deployment logs"
echo ""
echo "Auto-deployment is active (checks every 15 minutes)"
echo "Dialogues are logged in: $REPO_DIR/logs/"
echo ""
echo -e "${YELLOW}Note: Using HTTP (not HTTPS) since no domain is configured.${NC}"
echo -e "${YELLOW}If you want HTTPS later, you'll need a domain name.${NC}"
echo ""
