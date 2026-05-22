# ──────────────────────────────────────────────
# MONITORING - CloudWatch (dashboard + alarmas) y SNS
# ──────────────────────────────────────────────

resource "aws_sns_topic" "alertas" {
  name = "sns-alertas-${var.proyecto}"

  tags = {
    Name = "sns-alertas-${var.proyecto}"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alertas.arn
  protocol  = "email"
  endpoint  = var.email_alertas
}

resource "aws_cloudwatch_metric_alarm" "cpu_alta" {
  alarm_name          = "alarma-cpu-alta-${var.proyecto}"
  alarm_description   = "CPU promedio del ASG supera el umbral"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.umbral_cpu
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [aws_sns_topic.alertas.arn]
  ok_actions    = [aws_sns_topic.alertas.arn]
}

resource "aws_cloudwatch_metric_alarm" "memoria_alta" {
  alarm_name          = "alarma-memoria-alta-${var.proyecto}"
  alarm_description   = "Uso de memoria supera el umbral"
  namespace           = "CWAgent"
  metric_name         = "MemoriaUsadaPorcentaje"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.umbral_memoria
  comparison_operator = "GreaterThanThreshold"

  alarm_actions = [aws_sns_topic.alertas.arn]
  ok_actions    = [aws_sns_topic.alertas.arn]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_alta" {
  alarm_name          = "alarma-rds-cpu-${var.proyecto}"
  alarm_description   = "CPU de la instancia RDS supera el umbral"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.umbral_cpu
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }

  alarm_actions = [aws_sns_topic.alertas.arn]
  ok_actions    = [aws_sns_topic.alertas.arn]
}

resource "aws_cloudwatch_dashboard" "technova" {
  dashboard_name = "dashboard-${var.proyecto}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "CPU - Auto Scaling Group"
          region = var.aws_region
          view   = "timeSeries"
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Memoria - CloudWatch Agent"
          region = var.aws_region
          view   = "timeSeries"
          metrics = [
            ["CWAgent", "MemoriaUsadaPorcentaje"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Disco - CloudWatch Agent"
          region = var.aws_region
          view   = "timeSeries"
          metrics = [
            ["CWAgent", "DiscoUsadoPorcentaje"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Red y CPU - RDS MySQL"
          region = var.aws_region
          view   = "timeSeries"
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_identifier],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_identifier]
          ]
        }
      }
    ]
  })
}

# ──────────────────────────────────────────────
# BACKUP - AWS Backup para EC2 y RDS
# ──────────────────────────────────────────────

resource "aws_backup_vault" "technova" {
  name = "vault-${var.proyecto}"

  tags = {
    Name = "vault-${var.proyecto}"
  }
}

resource "aws_backup_plan" "technova" {
  name = "plan-backup-${var.proyecto}"

  rule {
    rule_name         = "respaldo-diario"
    target_vault_name = aws_backup_vault.technova.name

    schedule = "cron(0 5 * * ? *)"

    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = 30
    }
  }

  tags = {
    Name = "plan-backup-${var.proyecto}"
  }
}

resource "aws_iam_role" "backup" {
  name = "rol-backup-${var.proyecto}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_selection" "technova" {
  name         = "seleccion-${var.proyecto}"
  plan_id      = aws_backup_plan.technova.id
  iam_role_arn = aws_iam_role.backup.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Proyecto"
    value = "TechNova"
  }
}

# ──────────────────────────────────────────────
# CLOUDTRAIL - Auditoría y trazabilidad de la cuenta AWS
# ──────────────────────────────────────────────

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "cloudtrail-${var.proyecto}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "cloudtrail-${var.proyecto}"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PermitirCloudTrailVerACL"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "PermitirCloudTrailEscribirLogs"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "technova" {
  name                          = "cloudtrail-${var.proyecto}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  depends_on = [aws_s3_bucket_policy.cloudtrail]

  tags = {
    Name = "cloudtrail-${var.proyecto}"
  }
}
