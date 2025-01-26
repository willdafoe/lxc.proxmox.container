# Unifi Controller on Proxmox using Pulumi and Ansible

Welcome to the **Unifi Controller on Proxmox** project! This repository helps you deploy and configure a hardened LXC container on a Proxmox host, running the Unifi Controller application. We leverage the power of **Pulumi** for infrastructure as code (IaC) and **Ansible** for fine-tuning container configurations to meet security and hardening requirements.

---

## 🎯 Objectives

- **Deploy** a single LXC container on a Proxmox host.
- **Secure and Harden** the container for production use.
- **Run** the Unifi Controller application seamlessly.
- **Automate** everything with Pulumi and Ansible.

---

## 🛠️ Tech Stack

- **Proxmox**: Virtualization platform.
- **LXC**: Lightweight Linux containers.
- **Pulumi**: Infrastructure as Code tool.
- **Ansible**: Configuration management for secure and hardened environments.
- **Unifi Controller**: Network controller software for managing UniFi devices.

---

## 🚀 Quick Start

### 1. Prerequisites

- A working **Proxmox** host with API access enabled.
- **Pulumi CLI** installed ([Get Pulumi](https://www.pulumi.com/docs/get-started/install/)).
- **Node.js** installed (required for Pulumi).
- SSH keys set up for your Proxmox host and container access.

### 2. Clone the Repository

```bash
# Clone the repo
git clone https://github.com/yourusername/unifi-controller-proxmox.git
cd unifi-controller-proxmox
```

### 3. Configure Pulumi

1. Log in to Pulumi:

   ```bash
   pulumi login
   ```

2. Configure your Proxmox credentials:

   ```bash
   pulumi config set proxmox:host <your-proxmox-host>
   pulumi config set proxmox:username <your-proxmox-username>
   pulumi config set proxmox:password <your-proxmox-password> --secret
   ```

3. Set the LXC container configuration:

   ```bash
   pulumi config set container:memory 2048
   pulumi config set container:cpu 2
   pulumi config set container:storage <storage-pool-name>
   ```

### 4. Deploy and Configure the LXC Container

Run the Pulumi stack to deploy your container and execute the Ansible playbook automatically:

```bash
pulumi up
```

The Pulumi script will:
- Deploy the LXC container.
- Copy the necessary Ansible playbook to the container.
- Execute the Ansible playbook within the container to apply security and configuration settings.

### 5. Access the Unifi Controller

After the deployment finishes, the Unifi Controller should be accessible at:

```
https://<container-ip>:8443
```

---

## 🔒 Security and Hardening

The following configurations are applied for enhanced security:

- Firewall rules to restrict access to essential ports.
- SSH hardening (key-based authentication, disabling root login).
- Regular updates and package hardening.
- Limited container privileges.

---

## 🗂️ Project Structure

```plaintext
.
├── Pulumi.yaml              # Pulumi project configuration
├── Pulumi.<stack>.yaml      # Pulumi stack configuration
├── index.ts                 # Pulumi program (TypeScript)
├── playbooks/               # Ansible playbooks
│   └── harden_and_deploy_unifi.yml
├── inventory.ini            # Ansible inventory file
├── README.md                # Project documentation
└── .gitignore               # Ignored files
```

---

## 🧪 Testing

- Test the Pulumi deployment using:

  ```bash
  pulumi preview
  ```

- Verify the container's security with:

  ```bash
  ansible-playbook -i inventory.ini playbooks/verify_hardening.yml
  ```

---

## 🎨 Why Pulumi + Ansible?

By combining Pulumi and Ansible, you get the best of both worlds:

- **Pulumi** handles the infrastructure creation with modern programming languages.
- **Ansible** fine-tunes and secures the environment post-deployment, fully automated via Pulumi.

---

## 🛡️ Future Enhancements

- Add monitoring with Prometheus and Grafana.
- Automate SSL certificate provisioning with Let's Encrypt.
- Enable multi-controller support for scalability.
- Add CI/CD pipelines for continuous deployment.

---

## 🤝 Contributing

Feel free to fork this project and submit a pull request. Suggestions and improvements are always welcome!

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 💬 Questions or Feedback?

Reach out on GitHub Issues or email `youremail@example.com`. Let's make this project even better together!

---

Happy networking! 🌐
