provider "proxmox" {
  endpoint   = var.proxmox_api_url
  api_token  = var.proxmox_api_token
  insecure   = var.proxmox_insecure
}

resource "proxmox_lxc" "unifi" {
  target_node  = var.proxmox_host
  hostname     = var.lxc_hostname
  ostemplate   = var.lxc_template
  password     = var.lxc_password
  unprivileged = true
  cores        = var.cores
  memory       = var.memory
  swap         = var.swap
  features {
    nesting = true # Enable Docker inside LXC
  }
  rootfs {
    storage = var.storage
    size    = var.disk_size
  }
  network {
    name   = "eth0"
    bridge = var.network_bridge
    ip     = var.lxc_ip
    gw     = var.gateway
  }
  start = true

  provisioner "file" {
    source      = "${path.module}/provision.sh"
    destination = "/root/provision.sh"
    connection {
      type        = "ssh"
      user        = "root"
      password    = var.lxc_password
      host        = var.lxc_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/provision.sh",
      "/root/provision.sh"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      password    = var.lxc_password
      host        = var.lxc_ip
    }
  }
}
