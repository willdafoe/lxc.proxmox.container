variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Allow insecure TLS"
  type        = bool
  default     = false
}

variable "proxmox_host" {
  description = "Target Proxmox Node"
  type        = string
}

variable "lxc_hostname" {
  description = "LXC Hostname"
  type        = string
  default     = "unifi-controller"
}

variable "lxc_template" {
  description = "OS Template (Ubuntu LXC required)"
  type        = string
  default     = "local:vztmpl/ubuntu-22.04-standard_20230604_amd64.tar.zst"
}

variable "lxc_password" {
  description = "Root Password for LXC"
  type        = string
  sensitive   = true
}

variable "cores" {
  description = "CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory (MB)"
  type        = number
  default     = 2048
}

variable "swap" {
  description = "Swap Memory (MB)"
  type        = number
  default     = 1024
}

variable "storage" {
  description = "Storage Pool"
  type        = string
}

variable "disk_size" {
  description = "Disk Size (GB)"
  type        = string
  default     = "10G"
}

variable "network_bridge" {
  description = "Network Bridge"
  type        = string
  default     = "vmbr0"
}

variable "lxc_ip" {
  description = "LXC Static IP"
  type        = string
}

variable "gateway" {
  description = "Gateway IP"
  type        = string
}
