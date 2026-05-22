# ──────────────────────────────────────────────
# OUTPUTS - Valores útiles tras el despliegue
# ──────────────────────────────────────────────

output "alb_dns" {
  description = "DNS público del ALB - aquí accedes a la aplicación"
  value       = "http://${module.compute.alb_dns}"
}

output "rds_endpoint" {
  description = "Endpoint de conexión de la base de datos RDS"
  value       = module.database.rds_endpoint
}

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.networking.vpc_id
}

output "asg_nombre" {
  description = "Nombre del Auto Scaling Group"
  value       = module.compute.asg_name
}

output "sns_topic_arn" {
  description = "ARN del tema SNS de alertas"
  value       = module.observability.sns_topic_arn
}

output "dashboard_url" {
  description = "URL del dashboard de CloudWatch"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.observability.dashboard_name}"
}

output "backup_vault" {
  description = "Nombre de la bóveda de AWS Backup"
  value       = module.observability.backup_vault
}

output "cloudtrail_bucket" {
  description = "Bucket S3 donde CloudTrail guarda los registros de auditoría"
  value       = module.observability.cloudtrail_bucket
}
