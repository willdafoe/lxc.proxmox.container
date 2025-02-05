output "container_ip" {
  description = "IP Address of the LXC Container"
  value       = proxmox_lxc.unifi.network[0].ip
}

output "container_hostname" {
  description = "Hostname of the LXC Container"
  value       = proxmox_lxc.unifi.hostname
}
