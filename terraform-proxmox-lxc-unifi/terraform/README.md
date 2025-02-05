# **Terraform Module: Proxmox LXC Deployment**

This module automates the deployment of **LXC (Linux Containers)** on a **Proxmox VE host** using Terraform. It allows customization of container resources, networking, and storage.

---

## **📌 Features**
✅ Deploys an **unprivileged LXC container** on Proxmox  
✅ Uses a **custom OS template** (e.g., Ubuntu, Debian, Alpine)  
✅ Supports **static IP assignment & networking**  
✅ Configurable **CPU, RAM, disk, and swap** settings  
✅ **Auto-starts the container** on creation  

---

## **📜 Requirements**
- **Proxmox VE**: 7.0+  
- **Terraform**: 1.0+  
- **Proxmox Terraform Provider**  

**⚠️ Note:** Ensure you have a valid **LXC template** on your Proxmox host. You can check available templates:
```bash
pveam available
```

---

## **🛠️ Inputs**
| Variable | Description | Default |
|----------|------------|---------|
| **`proxmox_api_url`** | Proxmox API URL (e.g., `https://proxmox.example.com:8006/api2/json`) | **Required** |
| **`proxmox_api_token`** | API Token for authentication | **Required** |
| **`proxmox_host`** | Proxmox node where the LXC container will be deployed | **Required** |
| **`lxc_hostname`** | Hostname of the container | `"my-container"` |
| **`lxc_template`** | OS Template stored in Proxmox (e.g., `local:vztmpl/ubuntu-22.04.tar.gz`) | **Required** |
| **`lxc_password`** | Root password for the LXC container | **Required** |
| **`unprivileged`** | Run as an unprivileged container (recommended) | `true` |
| **`cores`** | CPU cores assigned to the container | `2` |
| **`memory`** | RAM allocation in MB | `1024` |
| **`swap`** | Swap memory in MB | `512` |
| **`storage`** | Proxmox storage pool for the container | **Required** |
| **`disk_size`** | Root disk size (e.g., `"10G"`) | `"10G"` |
| **`network_bridge`** | Network bridge to attach (`vmbr0` recommended) | `"vmbr0"` |
| **`lxc_ip`** | Static IP address (CIDR format, e.g., `"192.168.1.100/24"`) | **Required** |
| **`gateway`** | Default gateway for the container | **Required** |
| **`auto_start`** | Automatically start the container after deployment | `true` |

---

## **📤 Outputs**
| Output | Description |
|--------|------------|
| **`container_id`** | LXC Container ID |
| **`container_ip`** | Assigned IP address |
| **`container_hostname`** | Hostname of the LXC |

---

## **🚀 Example Usage**
```hcl
module "proxmox_lxc" {
  source            = "./terraform-proxmox-lxc"
  proxmox_api_url   = "https://proxmox.example.com:8006/api2/json"
  proxmox_api_token = "cicd@pve!cicd-token=your-api-token"
  proxmox_host      = "proxmox-node1"

  lxc_hostname     = "unifi-controller"
  lxc_template     = "local:vztmpl/ubuntu-22.04.tar.gz"
  lxc_password     = "securepassword"
  
  storage          = "local-lvm"
  disk_size        = "10G"
  cores            = 2
  memory           = 2048
  swap             = 1024

  lxc_ip           = "192.168.1.50/24"
  gateway          = "192.168.1.1"
}
```

---

## **📌 Additional Notes**
- **Custom Templates**: If you need to create a custom LXC template, use **Packer** or manually download an image:
  ```bash
  pveam download local ubuntu-22.04-standard_20230604_amd64.tar.zst
  ```
- **Proxmox API Authentication**: Ensure your API token has **sufficient permissions** (e.g., `PVEVMUser` or `PVEAdmin`).

---

## **🎯 Next Steps**
1. Run **Terraform Init**:
   ```bash
   terraform init
   ```
2. **Plan** your deployment:
   ```bash
   terraform plan
   ```
3. **Deploy** the LXC container:
   ```bash
   terraform apply -auto-approve
   ```

---

### **🛠️ Need Help?**
For issues or questions, feel free to reach out in the **Proxmox & Terraform communities**! 🚀

