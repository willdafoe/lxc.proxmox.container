#!/bin/bash

# Configuration
PROXMOX_HOST="https://10.1.0.148:8006"
PROXMOX_USER="pulumi@pve"
PROXMOX_API_TOKEN="6902d49d-4845-4eff-9d91-2b17c0fed219"
PROXMOX_API_HEADER="Authorization: PVEAPIToken=${PROXMOX_USER}!pulumi_api_token=${PROXMOX_API_TOKEN}"
INVENTORY_FILE="inventory.ini"
ANSIBLE_PLAYBOOK="playbooks/verify_hardening.yml"
PULUMI_STACK="homelab"  # Updated stack name to match `pulumi.homelab.yml`

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Function to check command existence
check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo -e "${RED}Error:${RESET} $1 is not installed. Please install it and try again."; exit 1; }
}

# Check required dependencies
echo -e "${YELLOW}Checking dependencies...${RESET}"
check_command pulumi
check_command ansible
check_command ssh
check_command curl
echo -e "${GREEN}All dependencies are installed.${RESET}"

# Verify Proxmox API connectivity using API token
echo -e "${YELLOW}Checking Proxmox API connectivity with API Token...${RESET}"
API_TEST=$(curl -s -k --header "$PROXMOX_API_HEADER" "${PROXMOX_HOST}/api2/json" | jq -r '.data | length')

if [[ "$API_TEST" != "null" ]]; then
    echo -e "${GREEN}Proxmox API authentication successful.${RESET}"
else
    echo -e "${RED}Error: Unable to authenticate with Proxmox API using the provided API token.${RESET}"
    exit 1
fi

# Configure Pulumi with API Token Authentication
echo -e "${YELLOW}Setting Pulumi Proxmox API credentials...${RESET}"
pulumi config set proxmox:host "$PROXMOX_HOST"
pulumi config set proxmox:username "$PROXMOX_USER"
pulumi config set proxmox:password "$PROXMOX_API_TOKEN" --secret

# Run Pulumi preview with correct stack
echo -e "${YELLOW}Running Pulumi preview...${RESET}"
pulumi preview --stack "${PULUMI_STACK}" || { echo -e "${RED}Pulumi preview failed.${RESET}"; exit 1; }

# Deploy LXC Container using Pulumi
echo -e "${YELLOW}Deploying LXC container with Pulumi...${RESET}"
pulumi up --yes --stack "${PULUMI_STACK}" || { echo -e "${RED}Pulumi deployment failed.${RESET}"; exit 1; }
echo -e "${GREEN}Pulumi deployment completed successfully.${RESET}"

# Wait for the container to be fully provisioned
echo -e "${YELLOW}Waiting for container initialization...${RESET}"
sleep 30  # Adjust based on deployment speed

# Verify hardening using Ansible playbook
echo -e "${YELLOW}Running Ansible hardening verification...${RESET}"
ansible-playbook -i "${INVENTORY_FILE}" "${ANSIBLE_PLAYBOOK}" || { echo -e "${RED}Ansible verification failed.${RESET}"; exit 1; }
echo -e "${GREEN}Ansible verification completed successfully.${RESET}"

echo -e "${GREEN}Deployment test completed successfully!${RESET}"
exit 0
