# ──────────────────────────────────────────────
# PROVIDER - Configuración de Terraform y AWS
# ──────────────────────────────────────────────
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Las credenciales se toman de variables de entorno
# (GitHub Actions: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN)
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Proyecto = "TechNova"
      Entorno  = "EP2-Cloud-II"
      Gestion  = "Terraform"
    }
  }
}

# ──────────────────────────────────────────────
# MÓDULOS
# ──────────────────────────────────────────────

module "networking" {
  source = "./modules/networking"

  vpc_cidr = var.vpc_cidr
  az_a     = var.az_a
  az_b     = var.az_b
  proyecto = var.proyecto
  mi_ip    = var.mi_ip
}

module "compute" {
  source = "./modules/compute"

  proyecto      = var.proyecto
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_id        = module.networking.vpc_id
  subnet_ids    = module.networking.public_subnet_ids
  sg_alb_id     = module.networking.sg_alb_id
  sg_ec2_id     = module.networking.sg_ec2_id
}

module "database" {
  source = "./modules/database"

  proyecto          = var.proyecto
  db_instance_class = var.db_instance_class
  db_master_username = var.db_master_username
  db_master_password = var.db_master_password
  db_name           = var.db_name
  subnet_ids        = module.networking.private_subnet_ids
  sg_rds_id         = module.networking.sg_rds_id
}

module "observability" {
  source = "./modules/observability"

  proyecto       = var.proyecto
  aws_region     = var.aws_region
  email_alertas  = var.email_alertas
  umbral_cpu     = var.umbral_cpu
  umbral_memoria = var.umbral_memoria
  asg_name       = module.compute.asg_name
  rds_identifier = module.database.rds_identifier
}
