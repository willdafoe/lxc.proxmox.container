#!/bin/bash

# Set script to exit on any errors
set -e

# Define repository structure
REPO_DIR="$HOME/lxc.proxmox.unifi.controller"
PACKER_DIR="$REPO_DIR/unifi-controller-proxmox/packer"
PACKER_TEMPLATE="$PACKER_DIR/ubuntu2004.pkr.hcl"
PACKER_VARS_FILE="$PACKER_DIR/ubuntu2004.pkrvars.hcl"

echo "🚀 Starting the Proxmox LXC container build process..."

# Step 1: Validate Packer Template
echo "🔍 Validating Packer template..."
packer fmt -check "$PACKER_TEMPLATE"
packer validate -var-file="$PACKER_VARS_FILE" "$PACKER_TEMPLATE"

# Step 2: Build LXC Container with Packer
echo "🏗️  Building LXC container with Packer..."
packer build -var-file="$PACKER_VARS_FILE" "$PACKER_TEMPLATE"

echo "🎉 Packer build complete!"