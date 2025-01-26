# Pulumi Program in Python for Deploying an LXC Container and Running Ansible

import pulumi
from pulumi_proxmoxve import Lxc
import subprocess
import os

# Load configurations
config = pulumi.Config()
proxmox_host = config.require("proxmox:host")
proxmox_user = config.require("proxmox:username")
proxmox_password = config.require_secret("proxmox:password")
memory = config.get_int("container:memory") or 2048
cpu = config.get_int("container:cpu") or 2
storage = config.require("container:storage")

container_name = "unifi-controller"
container_os = "debian-11"
ansible_playbook_path = "playbooks/harden_and_deploy_unifi.yml"

# Create the LXC container
lxc = Lxc(
    container_name,
    hostname=container_name,
    ostemplate=f"{proxmox_host}:local:vztmpl/{container_os}.tar.gz",
    memory=memory,
    cores=cpu,
    storage=storage,
    root_password="changeme",  # Replace with a secure method later
    network=[{"name": "eth0", "bridge": "vmbr0", "firewall": True}],
    options={"protect": True},
)

# Run Ansible Playbook after container creation
def run_ansible_playbook(ip):
    if not os.path.exists(ansible_playbook_path):
        raise FileNotFoundError(f"Ansible playbook not found at {ansible_playbook_path}")

    pulumi.log.info(f"Container IP: {ip}")
    command = f"ansible-playbook -i {ip}, {ansible_playbook_path}"
    try:
        subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as error:
        pulumi.log.error(f"Failed to execute Ansible playbook: {error}")
        raise error

# Get container IP and run the playbook
pulumi.Output.concat(lxc.hostname).apply(lambda container_id: 
    pulumi.Output.concat(lxc.ip).apply(run_ansible_playbook)
)

# Export container details
pulumi.export("container_details", {
    "name": container_name,
    "memory": memory,
    "cpu": cpu,
    "ip": lxc.ip,
})
