#!/bin/bash

set -e

echo "[+] Updating system..."
apt update && apt upgrade -y

echo "[+] Installing dependencies..."
apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg

echo "[+] Adding Docker repository..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo "[+] Installing Docker..."
apt update && apt install -y docker-ce docker-ce-cli containerd.io

echo "[+] Enabling Docker..."
systemctl enable --now docker

echo "[+] Deploying Unifi Controller..."
docker run -d --restart unless-stopped \
  --name unifi-controller \
  -p 8080:8080 \
  -p 8443:8443 \
  -p 3478:3478/udp \
  -e TZ="America/New_York" \
  jacobalberty/unifi

echo "[✔] Unifi Controller is running!"
