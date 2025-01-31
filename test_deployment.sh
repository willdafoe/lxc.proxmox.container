#!/bin/bash

# Configuration
PROXMOX_HOST="https://10.1.0.148:8006"
INVENTORY_FILE="inventory.ini"
ANSIBLE_PLAYBOOK="playbooks/verify_hardening.yml"
PULUMI_STACK="unifi-controller-proxmox"

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
echo -e "${GREEN}All dependencies are installed.${RESET}"

# Verify Proxmox API connectivity
echo -e "${YELLOW}Checking Proxmox API connectivity...${RESET}"
if curl -k -s --head --request GET "${PROXMOX_HOST}/api2/json" | grep "200 OK" >/dev/null; then
    echo -e "${GREEN}Proxmox API is reachable.${RESET}"
else
    echo -e "${RED}Error: Unable to connect to Proxmox API at ${PROXMOX_HOST}.${RESET}"
    exit 1
fi

# Run Pulumi preview
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
