output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.technova.id
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas (web)"
  value       = [aws_subnet.publica_a.id, aws_subnet.publica_b.id]
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas (datos)"
  value       = [aws_subnet.privada_datos_a.id, aws_subnet.privada_datos_b.id]
}

output "sg_alb_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb.id
}

output "sg_ec2_id" {
  description = "ID del Security Group de las EC2"
  value       = aws_security_group.ec2.id
}

output "sg_rds_id" {
  description = "ID del Security Group de RDS"
  value       = aws_security_group.rds.id
}
