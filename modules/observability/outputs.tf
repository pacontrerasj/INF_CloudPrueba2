output "sns_topic_arn" {
  description = "ARN del tema SNS de alertas"
  value       = aws_sns_topic.alertas.arn
}

output "dashboard_name" {
  description = "Nombre del dashboard de CloudWatch"
  value       = aws_cloudwatch_dashboard.technova.dashboard_name
}

output "backup_vault" {
  description = "Nombre de la bóveda de AWS Backup"
  value       = aws_backup_vault.technova.name
}

output "cloudtrail_bucket" {
  description = "Bucket S3 donde CloudTrail guarda los registros"
  value       = aws_s3_bucket.cloudtrail.id
}
