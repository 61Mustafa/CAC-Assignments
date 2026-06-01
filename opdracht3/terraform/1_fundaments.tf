#==================================================================
# 1_fundaments.tf
# Base VPC (10.0.0.0/16) met een public en private subnet in twee availability zones.
#==================================================================

data "aws_availability_zones" "available" {
  state = "available"
}
#============================
# VPC
#============================
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  # Zorgt ervoor dat servers gebruiksvriendelijke DNS namen krijgen
  enable_dns_hostnames = true

  tags = {
    Name = "VPC"
  }
}

#============================
# Subnets in AZ1
#============================
resource "aws_subnet" "az1_public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.az1_public_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  # Deel automatisch publieke IP adressen uit aan nieuwe servers.
  map_public_ip_on_launch = true

  tags = {
    Name = "PUBLIC-SUBNET-AZ1"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "az1_private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.az1_private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  # Geen publieke IP adressen uitdelen voor private instances.
  map_public_ip_on_launch = false

  tags = {
    Name = "PRIVATE-SUBNET-AZ1"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

#============================
# Subnets in AZ2
#============================
resource "aws_subnet" "az2_public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.az2_public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "PUBLIC-SUBNET-AZ2"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "az2_private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.az2_private_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "PRIVATE-SUBNET-AZ2"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

#======================================
# Internet Gateway & Route Tables
#======================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "INTERNETGATEWAY"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "PUBLIC-ROUTE-TABLE"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "PRIVATE-ROUTE-TABLE"
  }
}

# Default route voor publiek verkeer naar de Internet Gateway.
resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

#============================
# Route Table associations
#============================
resource "aws_route_table_association" "az1_public" {
  subnet_id      = aws_subnet.az1_public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "az2_public" {
  subnet_id      = aws_subnet.az2_public.id
  route_table_id = aws_route_table.public.id
}

#============================
# NAT Gateway
#============================
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "NAT-GATEWAY-EIP"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  # De NAT Gateway moet zelf in een publiek subnet staan om bij het internet te kunnen.
  subnet_id = aws_subnet.az1_public.id

  tags = {
    Name = "NAT-GATEWAY"
  }
  depends_on = [aws_internet_gateway.main]
}

# Default route voor private verkeer via de NAT Gateway.
resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "az1_private" {
  subnet_id      = aws_subnet.az1_private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "az2_private" {
  subnet_id      = aws_subnet.az2_private.id
  route_table_id = aws_route_table.private.id
}

#============================
# Firewalls (Security Groups)
#============================

resource "aws_security_group" "alb" {
  name        = "ALB-SECURITY-GROUP"
  description = "Sta HTTP verkeer toe vanaf het internet naar de Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP vanaf het internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB-SECURITY-GROUP"
  }
}

resource "aws_security_group" "web" {
  name        = "WEBSERVER-SECURITY-GROUP"
  description = "Sta HTTP uitsluitend toe via de ALB, en sta SSH toegang toe voor beheer."
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP uitsluitend via de ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH toegang voor beheer"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Alle interne communicatie tussen de webservers"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WEBSERVER-SECURITY-GROUP"
  }
}