output "server_public_ip" {
  description = "Public IP address of the application server"
  value       = var.server_public_ip  
  sensitive   = false
}
output "server_private_ip" {
  description = "Private IP address of the application server"
  value       = var.server_private_ip  
  sensitive   = false
}
output "server_ssh_user" {
  description = "SSH user for accessing the server"
  value       = "ubuntu"
  sensitive   = false
}
output "server_region" {
  description = "Region where the server is deployed"
  value       = var.region  
  sensitive   = false
}
output "ansible_inventory_entry" {
  description = "Entry to add to ansible inventory/hosts.yml"
  value       = <<-EOT
    akiba_server_prod:
      ansible_host: "${var.server_public_ip}"
      server_env: production
  EOT
  sensitive   = false
}
output "ansible_deployment_command" {
  description = "Command to run Ansible playbook after infrastructure creation"
  value       = <<-EOT
    cd ../ansible
    ansible-playbook configure.yml \
      -i inventory/hosts.yml \
      --ask-vault-pass \
      -e "mongodb_password=YOUR_MONGODB_PASSWORD"
  EOT
  sensitive   = false
}
output "ssh_connection_command" {
  description = "SSH command to connect to the server"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${var.server_public_ip}"
  sensitive   = false
}
output "health_check_url" {
  description = "URL to check application health"
  value       = "http://${var.server_public_ip}:3000/api/health"
  sensitive   = false
}
output "application_url" {
  description = "URL to access the AKIBA application"
  value       = "http://${var.server_public_ip}:3000"
  sensitive   = false
}
output "ansible_summary" {
  description = "Summary of Ansible deployment information"
  value = {
    infrastructure_created = true
    next_step              = "Run Ansible playbook to configure server"
    server_ip              = var.server_public_ip
    ssh_user               = "ubuntu"
    ssh_key_path           = "~/.ssh/id_rsa"
    inventory_file         = "ansible/inventory/hosts.yml"
    playbook               = "ansible/configure.yml"
    estimated_time         = "5-10 minutes"
    documentation          = "ansible/README.md"
  }
  sensitive = false
}
output "server_id" {
  description = "ID of the created server resource (for reference only)"
  value       = var.server_id  
  sensitive   = true
}
