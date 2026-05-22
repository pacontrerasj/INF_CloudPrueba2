# ──────────────────────────────────────────────
# VPC - Red de TechNova con cobertura en 2 AZ (HA)
# ──────────────────────────────────────────────

# -------------------------------------------------
# 1. VPC
# -------------------------------------------------
resource "aws_vpc" "technova" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.proyecto}"
  }
}

# -------------------------------------------------
# 2. Subnets
# -------------------------------------------------

resource "aws_subnet" "publica_a" {
  vpc_id                  = aws_vpc.technova.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.az_a
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-publica-web-1a"
  }
}

resource "aws_subnet" "publica_b" {
  vpc_id                  = aws_vpc.technova.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.az_b
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-publica-web-1b"
  }
}

resource "aws_subnet" "privada_datos_a" {
  vpc_id            = aws_vpc.technova.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az_a

  tags = {
    Name = "subnet-privada-datos-1a"
  }
}

resource "aws_subnet" "privada_datos_b" {
  vpc_id            = aws_vpc.technova.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az_b

  tags = {
    Name = "subnet-privada-datos-1b"
  }
}

# -------------------------------------------------
# 3. Internet Gateway
# -------------------------------------------------
resource "aws_internet_gateway" "technova" {
  vpc_id = aws_vpc.technova.id

  tags = {
    Name = "igw-${var.proyecto}"
  }
}

# -------------------------------------------------
# 4. Route Table pública
# -------------------------------------------------
resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.technova.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.technova.id
  }

  tags = {
    Name = "rt-publica-${var.proyecto}"
  }
}

resource "aws_route_table_association" "publica_a" {
  subnet_id      = aws_subnet.publica_a.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table_association" "publica_b" {
  subnet_id      = aws_subnet.publica_b.id
  route_table_id = aws_route_table.publica.id
}

# ──────────────────────────────────────────────
# SECURITY GROUPS - Seguridad por capas (3 niveles)
# ──────────────────────────────────────────────

resource "aws_security_group" "alb" {
  name        = "sg-alb-${var.proyecto}"
  description = "SG del Application Load Balancer - HTTP/HTTPS publico"
  vpc_id      = aws_vpc.technova.id

  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS publico"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Salida hacia las instancias EC2"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-alb-${var.proyecto}"
  }
}

resource "aws_security_group" "ec2" {
  name        = "sg-ec2-${var.proyecto}"
  description = "SG de instancias EC2 - trafico web solo desde el ALB"
  vpc_id      = aws_vpc.technova.id

  ingress {
    description     = "HTTP solo desde el ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "HTTPS solo desde el ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Backend 3001 solo desde el ALB"
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH desde mi IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.mi_ip]
  }

  egress {
    description = "Salida a internet (descarga de imagenes, updates)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-ec2-${var.proyecto}"
  }
}

resource "aws_security_group" "rds" {
  name        = "sg-rds-${var.proyecto}"
  description = "SG de RDS - MySQL solo desde las instancias EC2"
  vpc_id      = aws_vpc.technova.id

  ingress {
    description     = "MySQL 3306 solo desde sg-ec2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "Salida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-rds-${var.proyecto}"
  }
}
