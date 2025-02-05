data "proxmox_nodes" "nodes" {}

output "available_nodes" {
  description = "List of Proxmox nodes"
  value       = data.proxmox_nodes.nodes.nodes
}
