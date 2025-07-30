# Route 53 Health Checks + Failover Module Outputs

output "primary_health_check_id" {
  description = "ID of the primary health check"
  value       = var.enable_health_checks ? aws_route53_health_check.primary[0].id : null
}

output "primary_health_check_arn" {
  description = "ARN of the primary health check"
  value       = var.enable_health_checks ? aws_route53_health_check.primary[0].arn : null
}

output "backup_health_check_id" {
  description = "ID of the backup health check"
  value       = var.enable_health_checks && var.backup_endpoint != null ? aws_route53_health_check.backup[0].id : null
}

output "backup_health_check_arn" {
  description = "ARN of the backup health check"
  value       = var.enable_health_checks && var.backup_endpoint != null ? aws_route53_health_check.backup[0].arn : null
}

output "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.hosted_zone_id
}

output "hosted_zone_name_servers" {
  description = "Name servers of the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : null
}

output "primary_record_name" {
  description = "Name of the primary DNS record"
  value       = var.enable_health_checks ? aws_route53_record.primary[0].name : aws_route53_record.simple[0].name
}

output "primary_record_fqdn" {
  description = "FQDN of the primary DNS record"
  value       = var.enable_health_checks ? aws_route53_record.primary[0].fqdn : aws_route53_record.simple[0].fqdn
}

output "backup_record_name" {
  description = "Name of the backup DNS record"
  value       = var.enable_health_checks && var.backup_endpoint != null ? aws_route53_record.backup[0].name : null
}

output "backup_record_fqdn" {
  description = "FQDN of the backup DNS record"
  value       = var.enable_health_checks && var.backup_endpoint != null ? aws_route53_record.backup[0].fqdn : null
}

output "primary_cloudwatch_alarm_arn" {
  description = "ARN of the primary health check CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms && var.enable_health_checks ? aws_cloudwatch_metric_alarm.primary_health[0].arn : null
}

output "backup_cloudwatch_alarm_arn" {
  description = "ARN of the backup health check CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms && var.enable_health_checks && var.backup_endpoint != null ? aws_cloudwatch_metric_alarm.backup_health[0].arn : null
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for health check notifications"
  value       = var.enable_sns_notifications ? aws_sns_topic.health_notifications[0].arn : null
}

output "sns_topic_name" {
  description = "Name of the SNS topic for health check notifications"
  value       = var.enable_sns_notifications ? aws_sns_topic.health_notifications[0].name : null
}



output "module_summary" {
  description = "Summary of the DNS health check module configuration"
  value = {
    name_prefix           = var.name_prefix
    environment          = var.environment
    primary_endpoint     = var.primary_endpoint
    backup_endpoint      = var.backup_endpoint
    health_checks_enabled = var.enable_health_checks
    health_check_type    = var.health_check_type
    health_check_port    = var.health_check_port
    health_check_path    = var.health_check_path
    record_name          = var.record_name
    record_type          = var.record_type
    cloudwatch_alarms_enabled = var.enable_cloudwatch_alarms
    sns_notifications_enabled = var.enable_sns_notifications
    hosted_zone_created  = var.create_hosted_zone
    domain_name          = var.domain_name
  }
} 