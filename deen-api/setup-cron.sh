#!/bin/bash

# Script to set up cron job for auto-deployment
# Run this once on your VPS

REPO_DIR="/root/deen-buddy"
CRON_SCHEDULE="*/15 * * * *"  # Every 15 minutes

echo "Setting up auto-deploy cron job..."

# Make auto-deploy.sh executable
chmod +x "$REPO_DIR/auto-deploy.sh"

# Create cron job entry
CRON_JOB="$CRON_SCHEDULE $REPO_DIR/auto-deploy.sh >> $REPO_DIR/logs/cron.log 2>&1"

# Check if cron job already exists
(crontab -l 2>/dev/null | grep -F "$REPO_DIR/auto-deploy.sh") && {
    echo "Cron job already exists. Removing old entry..."
    crontab -l 2>/dev/null | grep -v "$REPO_DIR/auto-deploy.sh" | crontab -
}

# Add new cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "✓ Cron job added successfully!"
echo "  Schedule: Every 15 minutes"
echo "  Command: $REPO_DIR/auto-deploy.sh"
echo ""
echo "Current crontab:"
crontab -l

echo ""
echo "To view auto-deploy logs:"
echo "  tail -f $REPO_DIR/logs/auto-deploy.log"
echo ""
echo "To manually run deployment:"
echo "  $REPO_DIR/auto-deploy.sh"
