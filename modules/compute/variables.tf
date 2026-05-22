variable "proyecto" {
  description = "Nombre base del proyecto"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
}

variable "key_name" {
  description = "Nombre del key pair para SSH"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs de las subnets públicas"
  type        = list(string)
}

variable "sg_alb_id" {
  description = "ID del Security Group del ALB"
  type        = string
}

variable "sg_ec2_id" {
  description = "ID del Security Group de las EC2"
  type        = string
}
