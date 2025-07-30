# Advanced Example: Route 53 Health Checks + Failover
# This example demonstrates advanced usage with custom configurations

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create a new hosted zone for this example
resource "aws_route53_zone" "example" {
  name = "example.com"

  tags = {
    Name        = "example-zone"
    Environment = "dev"
    Purpose     = "DNS Health Check Example"
  }
}

# Advanced configuration with custom health check settings
module "dns_health_advanced" {
  source = "../../"

  name_prefix       = "example-advanced"
  environment      = "prod"
  primary_endpoint  = "primary-api.example.com"
  backup_endpoint   = "backup-api.example.com"
  
  # Advanced health check configuration
  health_check_type = "HTTPS"
  health_check_port = 443
  health_check_path = "/api/health"
  failure_threshold = 5
  request_interval  = 10
  timeout           = 8
  
  # DNS configuration
  record_name = "api"
  record_type = "A"
  
  # Create new hosted zone
  create_hosted_zone = true
  domain_name        = "example.com"
  
  # Advanced monitoring configuration
  enable_cloudwatch_alarms = true
  alarm_evaluation_periods = 3
  alarm_period             = 30
  
  # SNS notifications
  enable_sns_notifications = true
  notification_email       = "ops@example.com"
  
  # Custom alarm actions (example SNS topic ARNs)
  alarm_actions = [
    "arn:aws:sns:us-east-1:123456789012:ops-alerts",
    "arn:aws:sns:us-east-1:123456789012:pager-duty"
  ]
  
  ok_actions = [
    "arn:aws:sns:us-east-1:123456789012:ops-resolved"
  ]
  
  tags = {
    Project     = "Advanced DNS Health Check"
    Environment = "prod"
    Owner       = "SRE Team"
    CostCenter  = "IT-001"
    Compliance  = "SOX"
  }
}

# Simple configuration without health checks
module "dns_health_simple" {
  source = "../../"

  name_prefix       = "example-simple"
  environment      = "dev"
  primary_endpoint  = "simple.example.com"
  
  # Disable health checks for simple setup
  enable_health_checks = false
  
  # DNS configuration
  record_name = "simple"
  record_type = "A"
  
  # Use the hosted zone created above
  create_hosted_zone = false
  hosted_zone_id     = aws_route53_zone.example.zone_id
  
  # Disable monitoring for simple setup
  enable_cloudwatch_alarms = false
  enable_sns_notifications = false
  
  tags = {
    Project     = "Simple DNS Setup"
    Environment = "dev"
    Owner       = "Dev Team"
  }
}

# TCP health check example
module "dns_health_tcp" {
  source = "../../"

  name_prefix       = "example-tcp"
  environment      = "staging"
  primary_endpoint  = "tcp-primary.example.com"
  backup_endpoint   = "tcp-backup.example.com"
  
  # TCP health check configuration
  health_check_type = "TCP"
  health_check_port = 22  # SSH port example
  
  # DNS configuration
  record_name = "ssh"
  record_type = "A"
  
  # Use existing hosted zone
  create_hosted_zone = false
  hosted_zone_id     = aws_route53_zone.example.zone_id
  
  # Basic monitoring
  enable_cloudwatch_alarms = true
  enable_sns_notifications = true
  notification_email       = "admin@example.com"
  
  tags = {
    Project     = "TCP Health Check"
    Environment = "staging"
    Owner       = "Infrastructure Team"
  }
}

# Outputs for advanced example
output "advanced_primary_health_check_id" {
  description = "Advanced primary health check ID"
  value       = module.dns_health_advanced.primary_health_check_id
}

output "advanced_backup_health_check_id" {
  description = "Advanced backup health check ID"
  value       = module.dns_health_advanced.backup_health_check_id
}

output "advanced_primary_record_fqdn" {
  description = "Advanced primary DNS record FQDN"
  value       = module.dns_health_advanced.primary_record_fqdn
}

output "advanced_backup_record_fqdn" {
  description = "Advanced backup DNS record FQDN"
  value       = module.dns_health_advanced.backup_record_fqdn
}

output "advanced_sns_topic_arn" {
  description = "Advanced SNS topic ARN"
  value       = module.dns_health_advanced.sns_topic_arn
}

output "simple_record_fqdn" {
  description = "Simple DNS record FQDN"
  value       = module.dns_health_simple.primary_record_fqdn
}

output "tcp_primary_health_check_id" {
  description = "TCP primary health check ID"
  value       = module.dns_health_tcp.primary_health_check_id
}

output "hosted_zone_name_servers" {
  description = "Name servers for the hosted zone"
  value       = aws_route53_zone.example.name_servers
}

output "module_summaries" {
  description = "Summary of all module configurations"
  value = {
    advanced = module.dns_health_advanced.module_summary
    simple   = module.dns_health_simple.module_summary
    tcp      = module.dns_health_tcp.module_summary
  }
} 