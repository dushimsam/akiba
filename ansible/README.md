# Ansible Playbook for AKIBA Application Deployment

This directory contains Ansible playbooks and roles for configuring servers provisioned by Terraform to run the AKIBA containerized application.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Configuration](#configuration)
- [Running the Playbook](#running-the-playbook)
- [Inventory Management](#inventory-management)
- [Security Features](#security-features)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)

## Overview

The Ansible playbook automates the complete server configuration including:

- **Docker Installation**: Installs Docker and Docker Compose from official repositories
- **Application Deployment**: Deploys the AKIBA containerized application with PostgreSQL
- **Security Hardening**: 
  - Configures UFW firewall with minimal allowed ports
  - Hardens SSH configuration (disables password auth, root login)
  - Installs and configures fail2ban for intrusion detection
  - Applies latest security patches
- **Monitoring & Backup**: 
  - Configures systemd service for automatic restart
  - Sets up daily PostgreSQL backups
  - Implements health checks

## Prerequisites

### Terraform Outputs

Ensure your Terraform configuration outputs the server details needed by Ansible:

```hcl
# Add to your Terraform outputs.tf
output "server_ip" {
  value       = var.server_public_ip  # Your server's public IP
  description = "Server public IP address for Ansible"
}

output "server_user" {
  value       = "ubuntu"
  description = "SSH user for server"
}
```

### Local Requirements

- **Ansible**: Version 2.9 or higher
  ```bash
  pip install ansible>=2.9
  ```

- **SSH Key**: Private key for accessing the server
  ```bash
  ssh-keygen -t ed25519 -f ~/.ssh/id_rsa -N ""
  ```

- **Python**: On the target server (Ubuntu 24.04 includes Python 3.x)

### Target Server Requirements

- Ubuntu 20.04, 22.04, or 24.04 LTS
- SSH access with key-based authentication
- User account with sudo privileges (e.g., `ubuntu`)
- At least 2GB RAM and 20GB disk space
- Network access to Docker registries

## Directory Structure

```
ansible/
├── ansible.cfg                      # Ansible configuration file
├── configure.yml                    # Main playbook
├── vault-example.yml                # Example secrets (DO NOT COMMIT ACTUAL SECRETS)
├── inventory/
│   └── hosts.yml                    # Static inventory file
├── roles/
│   ├── docker/
│   │   └── tasks/
│   │       └── main.yml             # Docker installation tasks
│   ├── security/
│   │   ├── tasks/
│   │   │   └── main.yml             # Security hardening tasks
│   │   └── templates/
│   │       └── jail.local.j2        # fail2ban configuration template
│   └── application/
│       ├── tasks/
│       │   └── main.yml             # Application deployment tasks
│       └── templates/
│           ├── .env.j2              # Environment variables template
│           ├── akiba.service.j2     # Systemd service file template
│           ├── restart-app.sh.j2    # Application restart script
│           └── backup-db.sh.j2      # Database backup script
└── vars/
    └── default.yml                  # Default variables
```

## Configuration

### 1. Update the Inventory File

Edit `inventory/hosts.yml` with your server details:

```yaml
web_servers:
  hosts:
    akiba_server_prod:
      ansible_host: "YOUR_SERVER_IP"      # Replace with actual server IP
      server_env: production
```

### 2. Set PostgreSQL Credentials

Create a secure vault file for secrets:

```bash
cd ansible
ansible-vault create vault.yml
```

Add the following content:

```yaml
vault_postgres_password: "your_secure_password_123"
vault_sudo_password: "your_sudo_password"
```

### 3. Configure Variables (Optional)

Edit `vars/default.yml` to customize:
- `server_port`: Application port (default: 3000)
- `postgres_db`: Database name (default: akiba)
- `backup_schedule_hour`: Time for daily backups (default: 2 AM)
- `cors_origin`: CORS allowed origins (default: *)

### 4. Prepare SSH Access

Ensure your SSH key is added to the server's authorized_keys:

```bash
# Add your public key to the server (do this first via Terraform or manually)
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@YOUR_SERVER_IP
```

## Running the Playbook

### Basic Deployment

Run the complete playbook:

```bash
cd ansible
ansible-playbook configure.yml \
  -i inventory/hosts.yml \
  -e @vault.yml \
  -e "postgres_password=your_postgres_password"
```

### With Vault Password Prompt

```bash
ansible-playbook configure.yml \
  -i inventory/hosts.yml \
  --ask-vault-pass \
  -e "postgres_password=your_postgres_password"
```

### Run Specific Roles Only

Deploy only Docker and dependencies:

```bash
ansible-playbook configure.yml \
  -i inventory/hosts.yml \
  -e "postgres_password=your_postgres_password" \
  --tags docker
```

Deploy only security hardening:

```bash
ansible-playbook configure.yml \
  -i inventory/hosts.yml \
  --tags security
```

Deploy only the application:

```bash
ansible-playbook configure.yml \
  -i inventory/hosts.yml \
  -e "postgres_password=your_postgres_password" \
  --tags application
```

### Dry-Run (Check Mode)

Preview changes without applying:

```bash
ansible-playbook configure.yml \
  -i inventory/hosts.yml \
  -e @vault.yml \
  -e "postgres_password=your_postgres_password" \
  --check
```

### Verbose Output

For detailed debugging:

```bash
ansible-playbook configure.yml \
  -i inventory/hosts.yml \
  -e @vault.yml \
  -e "postgres_password=your_postgres_password" \
  -v                    # 1 level of verbosity
  # -vv                 # 2 levels
  # -vvv                # 3 levels (very verbose)
```

## Inventory Management

### Static Inventory (Current Setup)

The `inventory/hosts.yml` file is a static inventory. Update the `ansible_host` value with your server's IP address from Terraform output.

### Dynamic Inventory (Advanced)

For environments with multiple servers, you can create a dynamic inventory script that queries your infrastructure provider:

```bash
# Example: Create a script that fetches IPs from Terraform state
./scripts/dynamic_inventory.py
```

## Security Features

### 1. Firewall Configuration (UFW)

The playbook configures UFW with:
- **Incoming**: Deny by default, allow only SSH (22), HTTP (80), HTTPS (443), and app port (3000)
- **Outgoing**: Allow by default

Check firewall status:
```bash
sudo ufw status
sudo ufw show added
```

### 2. SSH Hardening

Applied security measures:
- ✓ Root login disabled
- ✓ Password authentication disabled (key-based only)
- ✓ Maximum 3 authentication attempts
- ✓ 20-second login grace time
- ✓ X11 forwarding disabled
- ✓ User access restricted to specific users

### 3. Fail2ban Intrusion Detection

Monitors SSH attempts and bans IPs after 3 failed attempts (1 hour ban):

```bash
# View fail2ban status
sudo fail2ban-client status sshd

# View banned IPs
sudo fail2ban-client set sshd unbanip 192.168.1.100
```

### 4. System Updates

The playbook applies all available security updates during deployment.

## Troubleshooting

### Cannot Connect to Server

```bash
# Test SSH connection
ssh -i ~/.ssh/id_rsa -v ubuntu@YOUR_SERVER_IP

# Verify key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### Ansible Connectivity Issues

```bash
# Ping the host
ansible web_servers -i inventory/hosts.yml -m ping

# Gather facts from host
ansible web_servers -i inventory/hosts.yml -m setup
```

### Docker Service Fails

```bash
# SSH to server and check Docker status
sudo systemctl status docker
sudo systemctl restart docker

# View Docker logs
sudo journalctl -u docker -f
```

### Application Not Starting

```bash
# Check Docker containers
docker ps -a

# View application logs
docker-compose -f /opt/akiba/docker-compose.yml logs -f

# Check service status
sudo systemctl status akiba
sudo journalctl -u akiba -f

# Perform health check
curl http://localhost:3000/api/health
```

### Firewall Blocking Traffic

```bash
# Check UFW rules
sudo ufw status numbered

# Allow a specific port temporarily
sudo ufw allow 3000/tcp

# Remove a rule
sudo ufw delete allow 3000/tcp
```

### PostgreSQL Connection Issues

```bash
# Connect to the PostgreSQL container
docker exec -it akiba-postgres psql -U akiba -d akiba

# Check container health
docker exec akiba-postgres pg_isready -U akiba -d akiba
```

## Advanced Usage

### Vault Management

```bash
# Create vault file
ansible-vault create vault.yml

# Edit vault file
ansible-vault edit vault.yml

# View vault file
ansible-vault view vault.yml

# Encrypt existing file
ansible-vault encrypt sensitive_file.yml

# Decrypt file
ansible-vault decrypt sensitive_file.yml

# Change vault password
ansible-vault rekey vault.yml
```

### Rolling Updates

Deploy to multiple servers sequentially:

```bash
ansible-playbook configure.yml \
  -i inventory/hosts.yml \
  -e @vault.yml \
  --serial 1              # Execute one host at a time
```

### Custom Variable Overrides

```bash
ansible-playbook configure.yml \
  -i inventory/hosts.yml \
  -e "server_port=8000" \
  -e "postgres_db=custom_db" \
  -e "node_env=staging"
```

### Gathering Specific Facts

```bash
# Gather network information
ansible web_servers -i inventory/hosts.yml -m setup -a "filter=ansible_net*"

# Gather all facts for debugging
ansible web_servers -i inventory/hosts.yml -m setup > facts.json
```

### Backup and Restore

Manual database backup:
```bash
ssh ubuntu@YOUR_SERVER_IP
/usr/local/bin/backup-akiba-db
```

List available backups:
```bash
sudo ls -lh /opt/akiba/backups/
```

### Application Restart

Via SSH:
```bash
ssh ubuntu@YOUR_SERVER_IP
/usr/local/bin/restart-akiba
```

Via systemd:
```bash
ssh ubuntu@YOUR_SERVER_IP
sudo systemctl restart akiba
```

### Viewing Logs

Systemd service logs:
```bash
sudo journalctl -u akiba -f
```

Docker container logs:
```bash
docker-compose -f /opt/akiba/docker-compose.yml logs -f
```

## Integration with Terraform

To fully automate the workflow, add this to your Terraform configuration:

```hcl
# In your main.tf or a new file terraform/ansible.tf

resource "null_resource" "run_ansible" {
  depends_on = [
    null_resource.wait_for_instance,  # Or your compute resource
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd ../ansible
      ansible-playbook configure.yml \
        -i inventory/hosts.yml \
        -e "ansible_host=${aws_instance.web.public_ip}" \
        --extra-vars @vault.yml \
        -e "postgres_password=${var.postgres_password}"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Ansible playbook execution would be retained for rollback'"
  }
}

output "ansible_inventory" {
  value       = "ansible/inventory/hosts.yml"
  description = "Path to Ansible inventory file"
}
```

Then run both together:
```bash
cd terraform
terraform apply
# Ansible will automatically run on successful infrastructure creation
```

## Best Practices

1. **Always use vault for secrets**: Never hardcode passwords
2. **Test in staging**: Run playbooks in a dev environment first
3. **Use check mode**: Always run with `--check` before production deployments
4. **Keep inventory updated**: Sync inventory with infrastructure changes
5. **Document custom variables**: Update `vars/default.yml` with any new variables
6. **Monitor logs**: Check systemd and Docker logs regularly
7. **Schedule backups**: Ensure backup cron jobs run successfully
8. **Review security settings**: Periodically review firewall and SSH configurations

## Performance Optimization

- Use `forks = 10` in ansible.cfg for parallel execution
- Enable pipelining: `pipelining = true` in ansible.cfg
- Use fact caching to skip fact gathering on subsequent runs
- Run specific tags to skip unnecessary tasks

## Support and Maintenance

For issues or questions:

1. Check application logs
2. Verify Ansible syntax: `ansible-lint configure.yml`
3. Review Ansible documentation: https://docs.ansible.com/
4. Check system logs: `sudo tail -f /var/log/syslog`

## License

This Ansible configuration is part of the AKIBA project and follows the same license terms.
