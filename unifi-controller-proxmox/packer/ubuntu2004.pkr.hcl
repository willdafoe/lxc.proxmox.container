packer {
  required_plugins {
    proxmox = {
      source = "github.com/hashicorp/proxmox"
      version = ">= 1.2.2"
    }
  }
}

source "proxmox" "ubuntu2004" {  # ❌ Change "proxmox-lxc" to "proxmox"
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
  sources = ["source.proxmox.ubuntu2004"]
}
