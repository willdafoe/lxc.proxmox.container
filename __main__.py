import pulumi
import pulumi_proxmoxve as proxmox
import pulumi.config

# Load Pulumi config values
config = pulumi.Config()
proxmox_host = config.require("proxmox:host")
proxmox_user = config.require("proxmox:username")
proxmox_api_token = config.require_secret("proxmox:password")  # Stored securely
container_memory = config.get_int("container:memory") or 2048
container_cpu = config.get_int("container:cpu") or 2
container_storage = config.get("container:storage") or "local-lvm"

# Define the Proxmox Provider with API Token authentication
proxmox_provider = proxmox.Provider(
    "proxmox",
    endpoint=proxmox_host,
    username=proxmox_user,
    api_token=proxmox_api_token,  # Securely passed
    insecure=True  # Set to False if using valid SSL certificates
)

# Deploy an LXC Container
container = proxmox.lxc.Container(
    "unifi-controller",
    node="pve",  # Change this to match your Proxmox node name
    hostname="unifi-controller",
    password="securepassword",  # Do NOT use this in production, use a secret instead
    ostemplate="local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst",
    cores=container_cpu,
    memory=container_memory,
    disk=[
        {
            "storage": container_storage,
            "size": "10G"
        }
    ],
    network=[
        {
            "name": "eth0",
            "bridge": "vmbr0",
            "ip": "dhcp"
        }
    ],
    provider=proxmox_provider  # Use the configured provider
)

# Export the container's IP address
pulumi.export("container_ip", container.ip_address)
