output "vpc_id" {
  value = aws_vpc.main.id
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "rds_endpoint" {
  value = aws_db_instance.sqlserver.address
}

output "ecr_repository_url" {
  value = aws_ecr_repository.webapp.repository_url
}

output "efs_id" {
  value = aws_efs_file_system.shared_logs.id
}
