#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

PROJECT_DIR="unifi-controller-proxmox"

# Define directory structure
declare -A directories=(
  ["$PROJECT_DIR/terraform"]="Terraform Configuration"
  ["$PROJECT_DIR/terraform/modules/lxc-container"]="Terraform LXC module"
  ["$PROJECT_DIR/packer"]="Packer Configuration"
  ["$PROJECT_DIR/packer/scripts"]="Packer setup scripts"
  ["$PROJECT_DIR/ansible"]="Ansible Configuration"
  ["$PROJECT_DIR/ansible/playbooks"]="Ansible Playbooks"
  ["$PROJECT_DIR/scripts"]="Deployment Scripts"
  ["$PROJECT_DIR/docs"]="Project Documentation"
  ["$PROJECT_DIR/.github/workflows"]="GitHub CI/CD Workflows"
)

# Ensure project root directory exists
mkdir -p "$PROJECT_DIR"

# Create directories
echo "🚀 Creating project directories..."
for dir in "${!directories[@]}"; do
  mkdir -p "$dir"
  echo "  ✅ Created: ${directories[$dir]} ($dir)"
done

# Ensure Terraform directory exists before writing files
mkdir -p "$PROJECT_DIR/terraform"

# Create Terraform files
echo "📌 Writing Terraform files..."
cat <<EOF > "$PROJECT_DIR/terraform/main.tf"
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_host
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = false
}

resource "proxmox_lxc" "unifi_controller" {
  hostname      = "unifi-controller"
  target_node   = "pve"
  ostemplate    = "local:vztmpl/ubuntu-2004-template.tar.gz"
  unprivileged  = true
  password      = var.container_root_password
  cores         = var.container_cpu
  memory        = var.container_memory

  rootfs {
    storage = var.container_storage
    size    = "16G"
  }

  network {
    name    = "eth0"
    bridge  = "vmbr0"
    ip      = "dhcp"
    firewall = true
  }

  ssh_public_keys = file(var.ssh_public_key_path)
}
EOF

echo "✅ Terraform main.tf created!"

cat <<EOF > "$PROJECT_DIR/terraform/variables.tf"
variable "proxmox_host" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "container_cpu" {
  description = "Number of CPU cores for LXC"
  type        = number
  default     = 2
}

variable "container_memory" {
  description = "Memory allocation in MB"
  type        = number
  default     = 2048
}

variable "container_storage" {
  description = "Storage pool"
  type        = string
}
EOF

echo "✅ Terraform variables.tf created!"

# Create Packer directory
mkdir -p "$PROJECT_DIR/packer"

# Create Packer files
echo "📌 Writing Packer files..."
cat <<EOF > "$PROJECT_DIR/packer/ubuntu2004.pkr.hcl"
packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = ">= 1.0.0"
    }
  }
}

source "proxmox-lxc" "ubuntu2004" {
  proxmox_url      = var.proxmox_api_url
  api_token_id     = var.proxmox_api_token_id
  api_token_secret = var.proxmox_api_token_secret

  node         = "pve"
  storage_pool = "local-lvm"
  ostemplate   = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  unprivileged = true
  password     = "packer"

  ssh_public_keys = file("~/.ssh/id_rsa.pub")

  provisioner "shell" {
    inline = [
      "apt update -y",
      "apt install -y software-properties-common"
    ]
  }
}

build {
  sources = ["source.proxmox-lxc.ubuntu2004"]
}
EOF

echo "✅ Packer ubuntu2004.pkr.hcl created!"

# Create Ansible directory
mkdir -p "$PROJECT_DIR/ansible"

# Create Ansible playbooks
echo "📌 Writing Ansible files..."
cat <<EOF > "$PROJECT_DIR/ansible/playbooks/install_unifi.yml"
- name: Install Unifi Controller
  hosts: unifi
  become: yes
  tasks:
    - name: Install required packages
      apt:
        name: ["ca-certificates", "curl", "openjdk-11-jre"]
        state: present

    - name: Add Unifi Repository
      shell: |
        echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E1F958385BFE2B6E

    - name: Install Unifi Controller
      apt:
        name: unifi
        state: present
EOF

echo "✅ Ansible install_unifi.yml created!"

# Create Scripts directory
mkdir -p "$PROJECT_DIR/scripts"

# Create Deployment Script
cat <<EOF > "$PROJECT_DIR/scripts/deploy.sh"
#!/bin/bash

set -e
echo "Initializing Terraform..."
cd ../terraform
terraform init
terraform apply -auto-approve

echo "Running Ansible Playbooks..."
cd ../ansible
ansible-playbook -i inventory.ini playbooks/install_unifi.yml
EOF

chmod +x "$PROJECT_DIR/scripts/deploy.sh"
echo "✅ Deployment script created!"

# Create README.md
cat <<EOF > "$PROJECT_DIR/README.md"
# Unifi Controller on Proxmox with Terraform, Packer, and Ansible

## Overview
This project automates the deployment of an LXC container running the Unifi Controller on Proxmox.

## Installation
1. Run Packer to build the LXC template:
   \`\`\`bash
   cd packer
   packer build ubuntu2004.pkr.hcl
   \`\`\`
2. Deploy with Terraform:
   \`\`\`bash
   cd terraform
   terraform apply -auto-approve
   \`\`\`
3. Configure with Ansible:
   \`\`\`bash
   cd ansible
   ansible-playbook -i inventory.ini playbooks/install_unifi.yml
   \`\`\`
EOF

echo "✅ Project README created!"

echo "🎉 Project setup complete! Navigate to $PROJECT_DIR and start building 🚀"
