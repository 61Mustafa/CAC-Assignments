#============================
# Regio
#============================
variable "aws_region" {
  description = "AWS regio waarin alles wordt uitgerold"
  type        = string
  default     = "us-east-1"
}

#============================
# CIDR Blocks
#============================
variable "vpc_cidr" {
  description = "IP reeks (CIDR) voor de VPC"
  type        = string
  default     = "10.0.0.0/16"
}

#============================
# Availability Zone 1 (AZ1)
#============================
variable "az1_public_subnet_cidr" {
  description = "IP-reeks (CIDR) voor het publieke subnet in AZ1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "az1_private_subnet_cidr" {
  description = "IP-reeks (CIDR) voor het private subnet in AZ1"
  type        = string
  default     = "10.0.51.0/24"
}

#============================
# Availability Zone 2 (AZ2)
#============================
variable "az2_public_subnet_cidr" {
  description = "IP-reeks (CIDR) voor het publieke subnet in AZ2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "az2_private_subnet_cidr" {
  description = "IP-reeks (CIDR) voor het private subnet in AZ2"
  type        = string
  default     = "10.0.52.0/24"
}

#============================
# Database Parameters
#============================
variable "db_user" {
  description = "Master username for the database"
  type        = string
  default     = "adminAWS"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  default     = "Komjenietin123"
  sensitive   = true
}

#============================
# EKS Parameters
#============================
variable "cluster_name" {
  description = "Naam van het EKS cluster"
  type        = string
  default     = "cloudshirt-eks"
}

variable "cluster_version" {
  description = "Kubernetes versie voor EKS (kies een momenteel ondersteunde versie)"
  type        = string
  default     = "1.33"
}