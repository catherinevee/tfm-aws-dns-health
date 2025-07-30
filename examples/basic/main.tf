# Basic Example: Route 53 Health Checks + Failover
# This example demonstrates basic usage of the module with health checks and failover

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
  region = "us-west-2"
}

# Basic configuration with health checks and failover
module "dns_health_basic" {
  source = "../../"

  name_prefix       = "example-basic"
  environment      = "dev"
  primary_endpoint  = "primary.example.com"
  backup_endpoint   = "backup.example.com"
  
  # Health check configuration
  health_check_type = "HTTP"
  health_check_port = 80
  health_check_path = "/health"
  
  # DNS configuration
  record_name = "api"
  record_type = "A"
  
  # Use existing hosted zone
  create_hosted_zone = false
  hosted_zone_id     = "Z1234567890ABC"  # Replace with your hosted zone ID
  
  # Enable monitoring
  enable_cloudwatch_alarms = true
  enable_sns_notifications = true
  notification_email       = "admin@example.com"
  
  tags = {
    Project     = "DNS Health Check Example"
    Environment = "dev"
    Owner       = "DevOps Team"
  }
}

# Output the results
output "primary_health_check_id" {
  description = "Primary health check ID"
  value       = module.dns_health_basic.primary_health_check_id
}

output "backup_health_check_id" {
  description = "Backup health check ID"
  value       = module.dns_health_basic.backup_health_check_id
}

output "primary_record_fqdn" {
  description = "Primary DNS record FQDN"
  value       = module.dns_health_basic.primary_record_fqdn
}

output "backup_record_fqdn" {
  description = "Backup DNS record FQDN"
  value       = module.dns_health_basic.backup_record_fqdn
}

output "sns_topic_arn" {
  description = "SNS topic ARN for notifications"
  value       = module.dns_health_basic.sns_topic_arn
} 