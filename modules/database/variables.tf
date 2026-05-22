variable "proyecto" {
  description = "Nombre base del proyecto"
  type        = string
}

variable "db_instance_class" {
  description = "Clase de instancia RDS"
  type        = string
}

variable "db_master_username" {
  description = "Usuario maestro de RDS"
  type        = string
}

variable "db_master_password" {
  description = "Contraseña del usuario maestro de RDS"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nombre de la base de datos inicial"
  type        = string
}

variable "subnet_ids" {
  description = "IDs de las subnets privadas (datos)"
  type        = list(string)
}

variable "sg_rds_id" {
  description = "ID del Security Group de RDS"
  type        = string
}
