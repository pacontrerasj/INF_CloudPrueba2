output "rds_endpoint" {
  description = "Endpoint de conexión de la base de datos RDS"
  value       = aws_db_instance.technova.endpoint
}

output "rds_identifier" {
  description = "Identificador de la instancia RDS"
  value       = aws_db_instance.technova.identifier
}
