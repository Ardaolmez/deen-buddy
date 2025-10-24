#!/bin/bash

# Auto-deploy script for deen-api
# This script pulls latest changes and restarts the API if needed

# Configuration
REPO_DIR="/root/deen-buddy"
LOG_FILE="/root/deen-buddy/logs/auto-deploy.log"
BRANCH="main"  # Change if using different branch

# Ensure logs directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Auto-deploy check started ==="

# Navigate to repo directory
cd "$REPO_DIR" || {
    log "ERROR: Failed to navigate to $REPO_DIR"
    exit 1
}

# Fetch latest changes
log "Fetching latest changes from remote..."
git fetch origin "$BRANCH" >> "$LOG_FILE" 2>&1

# Check if there are updates
LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse origin/"$BRANCH")

if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
    log "No updates available. Already up to date."
    exit 0
fi

log "Updates detected! Local: $LOCAL_HASH, Remote: $REMOTE_HASH"

# Stash any local changes (if any)
log "Stashing local changes (if any)..."
git stash >> "$LOG_FILE" 2>&1

# Pull latest changes
log "Pulling latest changes..."
git pull origin "$BRANCH" >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
    log "ERROR: Git pull failed!"
    exit 1
fi

log "Successfully pulled latest changes"

# Check if package.json changed
if git diff --name-only "$LOCAL_HASH" "$REMOTE_HASH" | grep -q "package.json"; then
    log "package.json changed, running npm install..."
    npm install >> "$LOG_FILE" 2>&1

    if [ $? -ne 0 ]; then
        log "ERROR: npm install failed!"
        exit 1
    fi

    log "Dependencies updated successfully"
fi

# Restart the application using PM2
log "Restarting application with PM2..."
pm2 restart deen-api >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    log "✓ Application restarted successfully"

    # Send notification (optional - uncomment if you want notifications)
    # curl -X POST "YOUR_WEBHOOK_URL" -H "Content-Type: application/json" \
    #   -d "{\"text\":\"deen-api deployed successfully at $(date)\"}"
else
    log "ERROR: Failed to restart application!"
    exit 1
fi

log "=== Auto-deploy completed successfully ==="
