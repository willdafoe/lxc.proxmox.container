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
