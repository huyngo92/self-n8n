#!/bin/bash

echo "--------- 🟢 Start install docker -----------"
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install -y docker-ce

# Add current user to docker group
sudo usermod -aG docker $USER
echo "--------- 🔴 Finish install docker -----------"

echo "--------- 🟢 Start creating folder -----------"
cd ~
mkdir -p vol_n8n
sudo chown -R 1000:1000 vol_n8n
sudo chmod -R 755 vol_n8n
echo "--------- 🔴 Finish creating folder -----------"

echo "--------- 🟢 Start Cloudflare Tunnel -----------"
sudo docker run -d --name cloudflare-tunnel \
  --restart unless-stopped \
  cloudflare/cloudflared:latest tunnel --no-autoupdate run \
  --token eyJhIjoiODg3MjFhNGQ4Y2E0ZjYyZmIyNGNkOWE3NTA3MWJhMTIiLCJ0IjoiZDRjYmNiMDUtYzI0Yi00OWZhLTk1YzItZjJjMzQ0NmIzMGJlIiwicyI6IllXVXpOV1E0TXpNdE16UXlPQzAwWVdNM0xUZzRNbVV0TmpnMk5XSXlNVFEzWTJFMyJ9
echo "--------- 🔴 Finish Cloudflare Tunnel -----------"

echo "--------- 🟢 Start docker compose up -----------"
wget https://raw.githubusercontent.com/huyngo92/self-n8n/refs/heads/main/compose_noai.yaml -O compose.yaml
export EXTERNAL_IP=https://hotromyss.site
export CURR_DIR=$(pwd)
sudo -E docker compose up -d
echo "--------- 🔴 Finish! Wait a few minutes and test in browser at url $EXTERNAL_IP for n8n UI -----------"
