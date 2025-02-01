packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = ">= 1.0.0"
    }
  }
}

variable "proxmox_api_url" {
  default = "https://your-proxmox-server:8006/api2/json"
}

variable "api_token_id" {}
variable "api_token_secret" {}
variable "storage_pool" {
  default = "local-lvm"
}
variable "ostemplate" {
  default = "local:vztmpl/ubuntu-20.04-standard_20230801.tar.gz"
}
variable "unprivileged" {
  default = true
}
variable "ssh_public_key" {}

source "proxmox" "ubuntu" {
  proxmox_api_url  = var.proxmox_api_url
  api_token_id     = var.api_token_id
  api_token_secret = var.api_token_secret

  vm_name          = "ubuntu-2004"
  node_name        = "proxmox-node"
  storage_pool     = var.storage_pool
  ostemplate       = var.ostemplate
  unprivileged     = var.unprivileged
  cores            = 2
  memory           = 2048
  disk_size        = "10G"
  ssh_public_key   = var.ssh_public_key
}

build {
  sources = ["source.proxmox.ubuntu"]

  provisioner "shell" {
    inline = [
      "apt update && apt upgrade -y",
      "echo 'Provisioning complete'"
    ]
  }
}
