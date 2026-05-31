#==================================================================
# 2_data_storage.tf
# MS SQL Server database (RDS) en een EFS netwerkschijf in de
# private subnets. Vertaling van 2_data&storage.yml (CloudFormation).
#==================================================================

#======================================
# Database (RDS)
#======================================

resource "aws_security_group" "rds" {
  name        = "RDS-SECURITY-GROUP"
  description = "Allow MS SQL SERVER traffic from Web Servers only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MS SQL Server uitsluitend vanaf de webservers"
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # Deze regel hoort hier (bij RDS), zodat de EKS worker nodes / pods
  # de database op poort 1433 kunnen bereiken.
  ingress {
    description     = "MS SQL Server vanaf de EKS worker nodes"
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  }

  # CloudFormation voegt standaard allow-all egress toe; Terraform niet.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS-SECURITY-GROUP"
  }
}

resource "aws_db_subnet_group" "main" {
  name        = "db-subnet-group"
  description = "Subnets for the RDS database"
  subnet_ids = [
    aws_subnet.az1_private.id,
    aws_subnet.az2_private.id,
  ]

  tags = {
    Name = "DB-SUBNET-GROUP"
  }
}

resource "aws_db_instance" "main" {
  engine            = "sqlserver-ex"
  instance_class    = "db.t3.small"
  license_model     = "license-included"
  allocated_storage = 20

  username = var.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false # SQL Server Express ondersteunt geen MultiAZ in RDS
  monitoring_interval = 0

  # CloudFormation maakt voor RDS standaard een final snapshot bij verwijderen.
  # Voor een lab/test omgeving willen we juist snel en zonder snapshot kunnen
  # afbreken (zoals je destroy.sh deed), dus skip_final_snapshot = true.
  skip_final_snapshot = true

  tags = {
    Name = "DATABASE"
  }
}

#======================================
# Elastic File System (EFS)
#======================================

resource "aws_security_group" "efs" {
  name        = "EFS-SECURITY-GROUP"
  description = "Allow NFS access from Web Servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "NFS uitsluitend vanaf de webservers"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EFS-SECURITY-GROUP"
  }
}

resource "aws_efs_file_system" "main" {
  encrypted = true

  tags = {
    Name = "CLOUDSHIRT-SHARED-LOGS"
  }
}

resource "aws_efs_mount_target" "az1" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.az1_private.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "az2" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.az2_private.id
  security_groups = [aws_security_group.efs.id]
}