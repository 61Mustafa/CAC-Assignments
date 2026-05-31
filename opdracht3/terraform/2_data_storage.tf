# Security Group voor RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow SQL Server traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # In de praktijk specifieker maken naar EKS nodes
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS-SG"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
  tags = {
    Name = "DB-Subnet-Group"
  }
}

# RDS SQL Server Instance
resource "aws_db_instance" "sqlserver" {
  identifier           = "cloudshirt-db"
  engine               = "sqlserver-ex"
  instance_class       = "db.t3.small"
  allocated_storage    = 20
  username             = "adminAWS"
  password             = "Komjenietin123" # In productie secret manager gebruiken
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
  license_model        = "license-included"
  publicly_accessible  = false

  tags = {
    Name = "CloudShirt-Database"
  }
}

# Security Group voor EFS
resource "aws_security_group" "efs_sg" {
  name        = "efs-security-group"
  description = "Allow NFS traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EFS-SG"
  }
}

# EFS File System
resource "aws_efs_file_system" "shared_logs" {
  creation_token = "cloudshirt-logs"
  encrypted      = true
  tags = {
    Name = "CloudShirt-SharedLogs"
  }
}

# EFS Mount Targets
resource "aws_efs_mount_target" "az1" {
  file_system_id  = aws_efs_file_system.shared_logs.id
  subnet_id       = aws_subnet.private_az1.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "az2" {
  file_system_id  = aws_efs_file_system.shared_logs.id
  subnet_id       = aws_subnet.private_az2.id
  security_groups = [aws_security_group.efs_sg.id]
}
