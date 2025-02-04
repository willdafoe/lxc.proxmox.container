# Proxmox API Credentials
proxmox_api_url    = "https://10.1.0.148:8006/api2/json"
api_token_id       = "your-api-token-id"
api_token_secret   = "your-api-token-secret"

# LXC/VM Settings
storage_pool       = "local-lvm"
ostemplate         = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
unprivileged       = true

# SSH Configuration
ssh_public_key     = "your-ssh-public-key"

# Other Configuration (Add as needed)
cpu_cores          = 2
memory             = 2048
