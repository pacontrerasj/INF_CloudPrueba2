# ──────────────────────────────────────────────
# RDS - Base de datos MySQL en Multi-AZ (Alta Disponibilidad)
# ──────────────────────────────────────────────

resource "aws_db_subnet_group" "technova" {
  name        = "subnet-group-${var.proyecto}"
  description = "Subnet group para RDS TechNova (subnets privadas, 2 AZ)"

  subnet_ids = [
    var.subnet_ids[0],
    var.subnet_ids[1],
  ]

  tags = {
    Name = "subnet-group-${var.proyecto}"
  }
}

resource "aws_db_instance" "technova" {
  identifier = "rds-${var.proyecto}"

  engine         = "mysql"
  engine_version = "8.4"

  instance_class = var.db_instance_class

  storage_type      = "gp3"
  allocated_storage = 50
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_master_username
  password = var.db_master_password

  db_subnet_group_name   = aws_db_subnet_group.technova.name
  vpc_security_group_ids = [var.sg_rds_id]
  publicly_accessible    = false

  multi_az = true

  backup_retention_period   = 7
  backup_window             = "03:00-04:00"
  maintenance_window        = "mon:04:00-mon:05:00"
  copy_tags_to_snapshot     = true
  delete_automated_backups  = false

  skip_final_snapshot = true

  tags = {
    Name = "rds-${var.proyecto}"
  }
}
