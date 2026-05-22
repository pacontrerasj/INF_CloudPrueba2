variable "proyecto" {
  description = "Nombre base del proyecto"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "email_alertas" {
  description = "Correo para notificaciones SNS"
  type        = string
}

variable "umbral_cpu" {
  description = "Umbral de CPU (%) para alarma"
  type        = number
}

variable "umbral_memoria" {
  description = "Umbral de memoria (%) para alarma"
  type        = number
}

variable "asg_name" {
  description = "Nombre del Auto Scaling Group"
  type        = string
}

variable "rds_identifier" {
  description = "Identificador de la instancia RDS"
  type        = string
}
