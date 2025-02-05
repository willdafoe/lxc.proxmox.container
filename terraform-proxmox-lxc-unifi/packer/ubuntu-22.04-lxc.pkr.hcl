# Packer Config to Build an Ubuntu 22.04 LXC Template for Proxmox
packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = ">=1.0.0"
    }
  }
}

variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
}

variable "proxmox_host" {
  description = "Proxmox node to build the template on"
  type        = string
}

variable "storage_pool" {
  description = "Storage pool to save the template"
  type        = string
  default     = "local"
}

source "proxmox-lxc" "ubuntu" {
  proxmox_api_url   = var.proxmox_api_url
  proxmox_api_token = var.proxmox_api_token

  node        = var.proxmox_host
  target_node = var.proxmox_host

  template_name   = "ubuntu-22.04-template"
  unprivileged    = true
  cores           = 2
  memory          = 1024
  swap            = 512
  storage         = var.storage_pool
  rootfs_size     = "8G"

  ostemplate = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.tar.gz"

  network {
    bridge = "vmbr0"
    ip     = "dhcp"
  }

  features {
    nesting = true
  }

  provisioner "shell" {
    inline = [
      "apt update && apt upgrade -y",
      "apt install -y curl wget nano sudo",
      "rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*"
    ]
  }
}

build {
  sources = ["source.proxmox-lxc.ubuntu"]

  post-processor "shell-local" {
    inline = ["echo 'LXC template created successfully!'"]
  }
}
