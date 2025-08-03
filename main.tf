# Route 53 Health Checks + Failover Module
# This module creates Route 53 health checks with automatic failover capabilities

# Route 53 Health Check for Primary Endpoint
resource "aws_route53_health_check" "primary" {
  count = var.enable_health_checks ? 1 : 0

  fqdn              = var.primary_endpoint
  port              = var.health_check_port # Default: 80
  type              = var.health_check_type # Default: HTTP
  resource_path     = var.health_check_path # Default: /
  failure_threshold = var.failure_threshold # Default: 3
  request_interval  = var.request_interval  # Default: 30
  timeout           = var.health_check_timeout # Default: 5
  search_string     = var.health_check_search_string # Default: null
  invert_healthcheck = var.invert_healthcheck # Default: false
  measure_latency   = var.measure_latency # Default: false
  regions           = var.health_check_regions # Default: ["us-east-1"]
  child_healthchecks = var.child_healthchecks # Default: []
  child_health_threshold = var.child_health_threshold # Default: 1
  enable_sni        = var.enable_sni # Default: false
  insufficient_data_health_status = var.insufficient_data_health_status # Default: null

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
  port              = var.health_check_port # Default: 80
  type              = var.health_check_type # Default: HTTP
  resource_path     = var.health_check_path # Default: /
  failure_threshold = var.failure_threshold # Default: 3
  request_interval  = var.request_interval  # Default: 30
  timeout           = var.health_check_timeout # Default: 5
  search_string     = var.health_check_search_string # Default: null
  invert_healthcheck = var.invert_healthcheck # Default: false
  measure_latency   = var.measure_latency # Default: false
  regions           = var.health_check_regions # Default: ["us-east-1"]
  child_healthchecks = var.child_healthchecks # Default: []
  child_health_threshold = var.child_health_threshold # Default: 1
  enable_sni        = var.enable_sni # Default: false
  insufficient_data_health_status = var.insufficient_data_health_status # Default: null

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
  comment = var.hosted_zone_comment # Default: "Managed by Terraform"
  force_destroy = var.hosted_zone_force_destroy # Default: false
  delegation_set_id = var.hosted_zone_delegation_set_id # Default: null

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
  type    = var.record_type # Default: A
  ttl     = var.ttl # Default: 300

  alias {
    name                   = var.primary_endpoint
    zone_id                = var.alias_zone_id
    evaluate_target_health = var.evaluate_target_health # Default: true
  }

  health_check_id = aws_route53_health_check.primary[0].id
  set_identifier  = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  latency_routing_policy {
    region = var.latency_routing_region # Default: null
  }

  geolocation_routing_policy {
    continent   = var.geolocation_continent # Default: null
    country     = var.geolocation_country # Default: null
    subdivision = var.geolocation_subdivision # Default: null
  }

  weighted_routing_policy {
    weight = var.weighted_routing_weight # Default: 1
  }

  multivalue_answer_routing_policy = var.multivalue_answer_routing_policy # Default: false
}

# Backup A Record with Health Check
resource "aws_route53_record" "backup" {
  count = var.enable_health_checks && var.backup_endpoint != null ? 1 : 0

  zone_id = var.hosted_zone_id != null ? var.hosted_zone_id : aws_route53_zone.main[0].zone_id
  name    = var.record_name
  type    = var.record_type # Default: A
  ttl     = var.ttl # Default: 300

  alias {
    name                   = var.backup_endpoint
    zone_id                = var.alias_zone_id
    evaluate_target_health = var.evaluate_target_health # Default: true
  }

  health_check_id = aws_route53_health_check.backup[0].id
  set_identifier  = "backup"

  failover_routing_policy {
    type = "SECONDARY"
  }

  latency_routing_policy {
    region = var.latency_routing_region # Default: null
  }

  geolocation_routing_policy {
    continent   = var.geolocation_continent # Default: null
    country     = var.geolocation_country # Default: null
    subdivision = var.geolocation_subdivision # Default: null
  }

  weighted_routing_policy {
    weight = var.weighted_routing_weight # Default: 1
  }

  multivalue_answer_routing_policy = var.multivalue_answer_routing_policy # Default: false
}

# Simple A Record (when health checks are disabled)
resource "aws_route53_record" "simple" {
  count = var.enable_health_checks ? 0 : 1

  zone_id = var.hosted_zone_id != null ? var.hosted_zone_id : aws_route53_zone.main[0].zone_id
  name    = var.record_name
  type    = var.record_type # Default: A
  ttl     = var.ttl # Default: 300

  alias {
    name                   = var.primary_endpoint
    zone_id                = var.alias_zone_id
    evaluate_target_health = var.evaluate_target_health # Default: true
  }
}

# CloudWatch Alarm for Primary Health Check
resource "aws_cloudwatch_metric_alarm" "primary_health" {
  count = var.enable_cloudwatch_alarms && var.enable_health_checks ? 1 : 0

  alarm_name          = "${var.name_prefix}-primary-health-alarm"
  comparison_operator = var.alarm_comparison_operator # Default: "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods # Default: 2
  metric_name         = var.alarm_metric_name # Default: "HealthCheckStatus"
  namespace           = var.alarm_namespace # Default: "AWS/Route53"
  period              = var.alarm_period # Default: 60
  statistic           = var.alarm_statistic # Default: "Average"
  threshold           = var.alarm_threshold # Default: 1.0
  alarm_description   = var.alarm_description # Default: "Primary endpoint health check failure"
  alarm_actions       = var.alarm_actions # Default: []
  ok_actions          = var.ok_actions # Default: []
  insufficient_data_actions = var.insufficient_data_actions # Default: []
  treat_missing_data  = var.treat_missing_data # Default: "missing"
  datapoints_to_alarm = var.datapoints_to_alarm # Default: null
  extended_statistic  = var.extended_statistic # Default: null
  unit                = var.alarm_unit # Default: null

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
  comparison_operator = var.alarm_comparison_operator # Default: "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods # Default: 2
  metric_name         = var.alarm_metric_name # Default: "HealthCheckStatus"
  namespace           = var.alarm_namespace # Default: "AWS/Route53"
  period              = var.alarm_period # Default: 60
  statistic           = var.alarm_statistic # Default: "Average"
  threshold           = var.alarm_threshold # Default: 1.0
  alarm_description   = var.alarm_description # Default: "Backup endpoint health check failure"
  alarm_actions       = var.alarm_actions # Default: []
  ok_actions          = var.ok_actions # Default: []
  insufficient_data_actions = var.insufficient_data_actions # Default: []
  treat_missing_data  = var.treat_missing_data # Default: "missing"
  datapoints_to_alarm = var.datapoints_to_alarm # Default: null
  extended_statistic  = var.extended_statistic # Default: null
  unit                = var.alarm_unit # Default: null

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
  display_name = var.sns_topic_display_name # Default: null
  kms_master_key_id = var.sns_topic_kms_key_id # Default: null
  fifo_topic = var.sns_topic_fifo # Default: false
  content_based_deduplication = var.sns_topic_content_based_deduplication # Default: false

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
  confirmation_timeout_in_minutes = var.sns_subscription_confirmation_timeout # Default: 1
  delivery_policy = var.sns_subscription_delivery_policy # Default: null
  filter_policy = var.sns_subscription_filter_policy # Default: null
  filter_policy_scope = var.sns_subscription_filter_policy_scope # Default: null
  raw_message_delivery = var.sns_subscription_raw_message_delivery # Default: false
  redrive_policy = var.sns_subscription_redrive_policy # Default: null
  subscription_role_arn = var.sns_subscription_role_arn # Default: null
} 