output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet (Bastion)"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet (App VM)"
  value       = aws_subnet.private.id
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_security_group_id" {
  description = "Security Group ID of Bastion Host"
  value       = aws_security_group.bastion.id
}

output "app_vm_private_ip" {
  description = "Private IP address of the Application VM"
  value       = aws_instance.app.private_ip
}

output "app_vm_security_group_id" {
  description = "Security Group ID of Application VM"
  value       = aws_security_group.app.id
}

output "app_vm_id" {
  description = "Instance ID of the Application VM"
  value       = aws_instance.app.id
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = var.enable_database ? aws_db_instance.main[0].endpoint : null
}

output "rds_hostname" {
  description = "RDS database hostname"
  value       = var.enable_database ? aws_db_instance.main[0].address : null
}

output "rds_port" {
  description = "RDS database port"
  value       = var.enable_database ? aws_db_instance.main[0].port : null
}

output "rds_database_name" {
  description = "RDS database name"
  value       = var.enable_database ? aws_db_instance.main[0].db_name : null
}

output "rds_username" {
  description = "RDS master username"
  value       = var.enable_database ? aws_db_instance.main[0].username : null
}

output "rds_security_group_id" {
  description = "Security Group ID for RDS"
  value       = aws_security_group.rds.id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.app.arn
}

output "ecr_registry_id" {
  description = "Registry ID for ECR"
  value       = aws_ecr_repository.app.registry_id
}

output "ssh_to_bastion" {
  description = "SSH command to connect to Bastion Host"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.bastion.public_ip}"
}

output "ssh_to_app_via_bastion" {
  description = "SSH command to connect to App VM via Bastion"
  value       = "ssh -i ~/.ssh/id_rsa -o ProxyCommand='ssh -i ~/.ssh/id_rsa -W %h:%p ubuntu@${aws_instance.bastion.public_ip}' ubuntu@${aws_instance.app.private_ip}"
}

output "ansible_inventory_bastion" {
  description = "Ansible inventory entry for Bastion"
  value = {
    host   = aws_instance.bastion.public_ip
    user   = "ubuntu"
    role   = "bastion"
  }
}

output "ansible_inventory_app" {
  description = "Ansible inventory entry for App VM"
  value = {
    host           = aws_instance.app.private_ip
    user           = "ubuntu"
    role           = "app"
    bastion_ip     = aws_instance.bastion.public_ip
    proxy_command  = "ssh -W %h:%p -q ubuntu@${aws_instance.bastion.public_ip}"
  }
}

output "database_connection_string" {
  description = "PostgreSQL connection string for the application"
  value = var.enable_database ? "postgresql://${aws_db_instance.main[0].username}:PASSWORD@${aws_db_instance.main[0].address}:${aws_db_instance.main[0].port}/${aws_db_instance.main[0].db_name}" : null
  sensitive = true
}


output "infrastructure_summary" {
  description = "Summary of provisioned infrastructure"
  value = {
    vpc_cidr                = var.vpc_cidr
    public_subnet_cidr      = var.public_subnet_cidr
    private_subnet_cidr     = var.private_subnet_cidr
    bastion_public_ip       = aws_instance.bastion.public_ip
    app_vm_private_ip       = aws_instance.app.private_ip
    app_vm_id               = aws_instance.app.id
    bastion_sg              = aws_security_group.bastion.name
    app_sg                  = aws_security_group.app.name
    rds_enabled             = var.enable_database
    rds_endpoint            = var.enable_database ? aws_db_instance.main[0].endpoint : "Not enabled"
    ecr_repository_url      = aws_ecr_repository.app.repository_url
    region                  = var.aws_region
    environment             = var.environment
  }
}
