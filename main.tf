# Route 53 Health Checks + Failover Module
# This module creates Route 53 health checks with automatic failover capabilities

# Route 53 Health Check for Primary Endpoint
resource "aws_route53_health_check" "primary" {
  count = var.enable_health_checks ? 1 : 0

  fqdn              = var.primary_endpoint
  port              = var.health_check_port
  type              = var.health_check_type
  resource_path     = var.health_check_path
  failure_threshold = var.failure_threshold
  request_interval  = var.request_interval

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-primary-health-check"
    Environment = var.environment
    Purpose     = "Primary endpoint health monitoring"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 Health Check for Backup Endpoint
resource "aws_route53_health_check" "backup" {
  count = var.enable_health_checks && var.backup_endpoint != null ? 1 : 0

  fqdn              = var.backup_endpoint
  port              = var.health_check_port
  type              = var.health_check_type
  resource_path     = var.health_check_path
  failure_threshold = var.failure_threshold
  request_interval  = var.request_interval

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-backup-health-check"
    Environment = var.environment
    Purpose     = "Backup endpoint health monitoring"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 Zone (if creating new hosted zone)
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0

  name = var.domain_name

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-hosted-zone"
    Environment = var.environment
  })
}

# Primary A Record with Health Check
resource "aws_route53_record" "primary" {
  count = var.enable_health_checks ? 1 : 0

  zone_id = var.hosted_zone_id != null ? var.hosted_zone_id : aws_route53_zone.main[0].zone_id
  name    = var.record_name
  type    = var.record_type

  alias {
    name                   = var.primary_endpoint
    zone_id                = var.alias_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.primary[0].id
  set_identifier  = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }
}

# Backup A Record with Health Check
resource "aws_route53_record" "backup" {
  count = var.enable_health_checks && var.backup_endpoint != null ? 1 : 0

  zone_id = var.hosted_zone_id != null ? var.hosted_zone_id : aws_route53_zone.main[0].zone_id
  name    = var.record_name
  type    = var.record_type

  alias {
    name                   = var.backup_endpoint
    zone_id                = var.alias_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.backup[0].id
  set_identifier  = "backup"

  failover_routing_policy {
    type = "SECONDARY"
  }
}

# Simple A Record (when health checks are disabled)
resource "aws_route53_record" "simple" {
  count = var.enable_health_checks ? 0 : 1

  zone_id = var.hosted_zone_id != null ? var.hosted_zone_id : aws_route53_zone.main[0].zone_id
  name    = var.record_name
  type    = var.record_type

  alias {
    name                   = var.primary_endpoint
    zone_id                = var.alias_zone_id
    evaluate_target_health = true
  }
}

# CloudWatch Alarm for Primary Health Check
resource "aws_cloudwatch_metric_alarm" "primary_health" {
  count = var.enable_cloudwatch_alarms && var.enable_health_checks ? 1 : 0

  alarm_name          = "${var.name_prefix}-primary-health-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 1.0
  alarm_description   = "Primary endpoint health check failure"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary[0].id
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-primary-health-alarm"
    Environment = var.environment
  })
}

# CloudWatch Alarm for Backup Health Check
resource "aws_cloudwatch_metric_alarm" "backup_health" {
  count = var.enable_cloudwatch_alarms && var.enable_health_checks && var.backup_endpoint != null ? 1 : 0

  alarm_name          = "${var.name_prefix}-backup-health-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 1.0
  alarm_description   = "Backup endpoint health check failure"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    HealthCheckId = aws_route53_health_check.backup[0].id
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-backup-health-alarm"
    Environment = var.environment
  })
}

# SNS Topic for Health Check Notifications
resource "aws_sns_topic" "health_notifications" {
  count = var.enable_sns_notifications ? 1 : 0

  name = "${var.name_prefix}-health-notifications"

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-health-notifications-topic"
    Environment = var.environment
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "health_notifications" {
  count = var.enable_sns_notifications ? 1 : 0

  arn = aws_sns_topic.health_notifications[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.health_notifications[0].arn
      }
    ]
  })
}

# SNS Topic Subscription (if email is provided)
resource "aws_sns_topic_subscription" "email" {
  count = var.enable_sns_notifications && var.notification_email != null ? 1 : 0

  topic_arn = aws_sns_topic.health_notifications[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
} 