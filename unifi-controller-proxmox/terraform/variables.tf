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
