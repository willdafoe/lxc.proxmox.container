#!/bin/bash

set -e

# Define variables
ROOT_DIR=$(dirname "$0")
INVENTORY="$ROOT_DIR/inventory.ini"
SITE_PLAYBOOK="$ROOT_DIR/playbooks/site.yml"
VERIFY_PLAYBOOK="$ROOT_DIR/playbooks/verify_hardening.yml"

# Function to cleanup the deployment
cleanup() {
    echo "[INFO] Cleaning up test deployment..."
    ansible all -i $INVENTORY -m shell -a "systemctl stop unifi"
    ansible all -i $INVENTORY -m shell -a "apt-get remove --purge -y unifi"
    ansible all -i $INVENTORY -m shell -a "rm -rf /var/lib/unifi /etc/unifi /tmp/unifi_controller.deb"
    echo "[INFO] Cleanup completed."
    exit 0
}

# Check for cleanup flag
if [[ "$1" == "--cleanup" ]]; then
    cleanup
fi

# Ensure Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "[ERROR] Ansible is not installed. Please install it and try again."
    exit 1
fi

# Print project tree
echo "[INFO] Project directory structure:"
tree "$ROOT_DIR"

# Run the deployment playbook
echo "[INFO] Running Ansible deployment..."
ansible-playbook -i $INVENTORY $SITE_PLAYBOOK

# Run verification playbook
echo "[INFO] Verifying hardening and security settings..."
ansible-playbook -i $INVENTORY $VERIFY_PLAYBOOK

# Check Unifi Controller service status
echo "[INFO] Checking Unifi Controller status..."
ansible all -i $INVENTORY -m shell -a "systemctl status unifi --no-pager"

# Retrieve Unifi Controller logs
echo "[INFO] Fetching Unifi Controller logs..."
ansible all -i $INVENTORY -m shell -a "journalctl -u unifi --no-pager | tail -n 20"

echo "[INFO] Deployment test completed successfully!"
