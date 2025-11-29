#!/bin/bash

echo "--------- 🟢 Start updating domain -----------"

# Stop current containers
echo "Stopping containers..."
cd ~
sudo -E docker compose down

# Update domain
read -p "Enter new domain (e.g., https://hotromyss.site): " new_domain
export EXTERNAL_IP=$new_domain
export CURR_DIR=$(pwd)

# Restart containers with new domain
echo "Restarting containers with new domain: $EXTERNAL_IP"
sudo -E docker compose up -d

echo "--------- 🔴 Finish! Wait a few minutes and test in browser at url $EXTERNAL_IP for n8n UI -----------"
