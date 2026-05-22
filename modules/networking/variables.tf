variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC"
  type        = string
}

variable "az_a" {
  description = "Primera zona de disponibilidad"
  type        = string
}

variable "az_b" {
  description = "Segunda zona de disponibilidad (para HA)"
  type        = string
}

variable "proyecto" {
  description = "Nombre base del proyecto"
  type        = string
}

variable "mi_ip" {
  description = "IP pública en formato CIDR para acceso SSH"
  type        = string
}
