#==================================================================
# 3_eks.tf
# Managed Kubernetes (EKS): cluster (master), node group (workers)
# en ECR repository. Vervangt de Swarm-applicatielaag uit
# 3_application&loadbalancer.yml.
#==================================================================

# In de AWS Academy Learner Lab mogen we GEEN eigen IAM-rollen maken.
# We hergebruiken daarom de bestaande LabRole voor zowel de control
# plane als de worker nodes.
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

#======================================
# ECR Repository (REQ-18)
#======================================
resource "aws_ecr_repository" "cloudshirt" {
  name         = "cloudshirt-repo"
  force_delete = true # equivalent van EmptyOnDelete in CloudFormation

  tags = {
    Name = "CLOUDSHIRT-ECR"
  }
}

#======================================
# EKS Cluster (de "Master" - REQ-19/20)
#======================================
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = data.aws_iam_role.lab_role.arn

  vpc_config {
    # Control plane spreidt over beide AZ's; publieke subnets erbij zodat
    # een Service van type LoadBalancer straks een extern IP kan plaatsen.
    subnet_ids = [
      aws_subnet.az1_private.id,
      aws_subnet.az2_private.id,
      aws_subnet.az1_public.id,
      aws_subnet.az2_public.id,
    ]
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  tags = {
    Name = var.cluster_name
  }
}

#======================================
# Managed Node Group (de "Slave"/workers - REQ-20)
#======================================
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "cloudshirt-workers"
  node_role_arn   = data.aws_iam_role.lab_role.arn

  # Worker nodes in de private subnets; bereiken ECR/internet via de NAT Gateway.
  subnet_ids = [
    aws_subnet.az1_private.id,
    aws_subnet.az2_private.id,
  ]

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }
}