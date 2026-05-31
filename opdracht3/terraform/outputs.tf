#============================
# Outputs (fundament)
# Vervangen de CloudFormation Exports. Binnen één Terraform project
# verwijzen latere bestanden direct naar de resources; deze outputs
# zijn handig voor inzicht en eventueel gebruik via remote_state.
#============================

output "vpc_id" {
  description = "Een verwijzing naar de aangemaakte VPC"
  value       = aws_vpc.main.id
}

output "aws_region" {
  description = "De AWS regio"
  value       = var.aws_region
}

output "az1_private_subnet_id" {
  description = "Verwijzing naar het private subnet in AZ1"
  value       = aws_subnet.az1_private.id
}

output "az2_private_subnet_id" {
  description = "Verwijzing naar het private subnet in AZ2"
  value       = aws_subnet.az2_private.id
}

output "az1_public_subnet_id" {
  description = "Verwijzing naar het publieke subnet in AZ1"
  value       = aws_subnet.az1_public.id
}

output "az2_public_subnet_id" {
  description = "Verwijzing naar het publieke subnet in AZ2"
  value       = aws_subnet.az2_public.id
}

output "web_server_security_group_id" {
  description = "Verwijzing naar de veilige firewall van de webservers"
  value       = aws_security_group.web.id
}

output "alb_security_group_id" {
  description = "Verwijzing naar de publieke firewall van de Load Balancer"
  value       = aws_security_group.alb.id
}

#============================
# Outputs (data & storage)
#============================
output "efs_file_system_id" {
  description = "Reference to the shared EFS drive ID"
  value       = aws_efs_file_system.main.id
}

output "database_endpoint" {
  description = "Connection endpoint (hostname) for the RDS Database"
  value       = aws_db_instance.main.address
}

#============================
# Outputs (EKS / ECR)
#============================
output "ecr_repository_url" {
  description = "URL van de ECR repository (REQ-18)"
  value       = aws_ecr_repository.cloudshirt.repository_url
}

output "eks_cluster_name" {
  description = "Naam van het EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "API endpoint van het EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}