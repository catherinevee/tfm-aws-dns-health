# Basic Terraform test for DNS Health Check module
# Tests basic functionality with health checks enabled

variables {
  name_prefix       = "test-dns-health"
  environment      = "test"
  primary_endpoint  = "test.example.com"
  backup_endpoint   = "backup.example.com"
  enable_health_checks = true
  health_check_type = "HTTP"
  health_check_port = 80
  health_check_path = "/health"
  record_name       = "api"
  record_type       = "A"
  create_hosted_zone = true
  domain_name       = "test.example.com"
  enable_cloudwatch_alarms = true
  enable_sns_notifications = true
  notification_email = "test@example.com"
  tags = {
    Environment = "test"
    Purpose     = "testing"
  }
}

run "basic_health_check_creation" {
  command = plan

  assert {
    condition     = aws_route53_health_check.primary[0].fqdn == "test.example.com"
    error_message = "Primary health check should be created with correct FQDN."
  }

  assert {
    condition     = aws_route53_health_check.backup[0].fqdn == "backup.example.com"
    error_message = "Backup health check should be created with correct FQDN."
  }

  assert {
    condition     = aws_route53_health_check.primary[0].type == "HTTP"
    error_message = "Health check type should be HTTP."
  }

  assert {
    condition     = aws_route53_health_check.primary[0].port == 80
    error_message = "Health check port should be 80."
  }

  assert {
    condition     = aws_route53_health_check.primary[0].resource_path == "/health"
    error_message = "Health check path should be /health."
  }
}

run "dns_record_creation" {
  command = plan

  assert {
    condition     = aws_route53_record.primary[0].name == "api"
    error_message = "Primary DNS record should be created with correct name."
  }

  assert {
    condition     = aws_route53_record.primary[0].type == "A"
    error_message = "DNS record type should be A."
  }

  assert {
    condition     = aws_route53_record.backup[0].name == "api"
    error_message = "Backup DNS record should be created with correct name."
  }
}

run "cloudwatch_alarm_creation" {
  command = plan

  assert {
    condition     = aws_cloudwatch_metric_alarm.primary_health[0].metric_name == "HealthCheckStatus"
    error_message = "CloudWatch alarm should be created with correct metric name."
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.primary_health[0].namespace == "AWS/Route53"
    error_message = "CloudWatch alarm should be created with correct namespace."
  }
}

run "sns_topic_creation" {
  command = plan

  assert {
    condition     = aws_sns_topic.health_notifications[0].name == "test-dns-health-health-notifications"
    error_message = "SNS topic should be created with correct name."
  }

  assert {
    condition     = aws_sns_topic_subscription.email[0].protocol == "email"
    error_message = "SNS subscription should be created with email protocol."
  }
}

run "hosted_zone_creation" {
  command = plan

  assert {
    condition     = aws_route53_zone.main[0].name == "test.example.com"
    error_message = "Hosted zone should be created with correct domain name."
  }
}

run "output_validation" {
  command = plan

  assert {
    condition     = output.primary_health_check_id != null
    error_message = "Primary health check ID output should not be null."
  }

  assert {
    condition     = output.backup_health_check_id != null
    error_message = "Backup health check ID output should not be null."
  }

  assert {
    condition     = output.hosted_zone_id != null
    error_message = "Hosted zone ID output should not be null."
  }

  assert {
    condition     = output.sns_topic_arn != null
    error_message = "SNS topic ARN output should not be null."
  }
} 