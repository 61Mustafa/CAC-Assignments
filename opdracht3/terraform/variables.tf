variable "aws_region" {
  description = "De AWS regio waar de resources worden aangemaakt"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Naam van het EKS cluster"
  type        = string
  default     = "cloudshirt-cluster"
}
