output "alb_dns" {
  description = "DNS público del ALB"
  value       = aws_lb.technova.dns_name
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group"
  value       = aws_autoscaling_group.technova.name
}

output "alb_tg_arn" {
  description = "ARN del Target Group del ALB"
  value       = aws_lb_target_group.technova.arn
}
