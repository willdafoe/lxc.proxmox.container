#!/bin/bash

# Variables
REPO_URL="https://github.com/willdafoe/lxc.proxmox.container.git"
CLONE_DIR="$HOME/lxc.proxmox.container"
PACKER_VARS_FILE="$CLONE_DIR/unifi-controller-proxmox/packer/ubuntu2004.pkrvars.hcl"
RUN_SCRIPT="$CLONE_DIR/unifi-controller-proxmox/run.sh"

# Detect Proxmox API URL
PROXMOX_HOSTNAME=$(hostname)
PROXMOX_API_URL="https://$PROXMOX_HOSTNAME:8006/api2/json"

# Clone the repository
if [ ! -d "$CLONE_DIR" ]; then
    echo "🚀 Cloning repository..."
    git clone "$REPO_URL" "$CLONE_DIR"
else
    echo "✅ Repository already exists. Pulling latest changes..."
    cd "$CLONE_DIR" && git pull
fi

# Ensure the target directory exists
mkdir -p "$(dirname "$PACKER_VARS_FILE")"

# Generate Packer variables file
cat > "$PACKER_VARS_FILE" <<EOF
proxmox_api_url    = "$PROXMOX_API_URL"
api_token_id       = "your_proxmox_api_token_id"
api_token_secret   = "your_proxmox_api_token_secret"
EOF

echo "✅ Packer variables file created: $PACKER_VARS_FILE"

# Run Packer build script
if [ -f "$RUN_SCRIPT" ]; then
    echo "🚀 Running Packer build script..."
    chmod +x "$RUN_SCRIPT"
    "$RUN_SCRIPT"
else
    echo "❌ Error: Packer run script not found: $RUN_SCRIPT"
    exit 1
fi

echo "🎉 Packer setup and execution complete!"
