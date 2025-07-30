# Test Configuration for Route 53 Health Checks + Failover Module
# This configuration is used for testing the module functionality

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

# Test hosted zone
resource "aws_route53_zone" "test" {
  name = "test.example.com"

  tags = {
    Name        = "test-zone"
    Environment = "test"
    Purpose     = "Module Testing"
  }
}

# Test the module with health checks enabled
module "dns_health_test" {
  source = "../"

  name_prefix       = "test-health"
  environment      = "test"
  primary_endpoint  = "test-primary.example.com"
  backup_endpoint   = "test-backup.example.com"
  
  # Health check configuration
  health_check_type = "HTTP"
  health_check_port = 80
  health_check_path = "/health"
  failure_threshold = 2
  request_interval  = 10
  timeout           = 5
  
  # DNS configuration
  record_name = "test-api"
  record_type = "A"
  
  # Use test hosted zone
  create_hosted_zone = false
  hosted_zone_id     = aws_route53_zone.test.zone_id
  
  # Enable monitoring
  enable_cloudwatch_alarms = true
  enable_sns_notifications = true
  notification_email       = "test@example.com"
  
  tags = {
    Project     = "Module Testing"
    Environment = "test"
    Owner       = "Test Team"
  }
}

# Test the module without health checks
module "dns_health_simple_test" {
  source = "../"

  name_prefix       = "test-simple"
  environment      = "test"
  primary_endpoint  = "test-simple.example.com"
  
  # Disable health checks
  enable_health_checks = false
  
  # DNS configuration
  record_name = "test-simple"
  record_type = "A"
  
  # Use test hosted zone
  create_hosted_zone = false
  hosted_zone_id     = aws_route53_zone.test.zone_id
  
  # Disable monitoring
  enable_cloudwatch_alarms = false
  enable_sns_notifications = false
  
  tags = {
    Project     = "Simple Test"
    Environment = "test"
    Owner       = "Test Team"
  }
}

# Test outputs
output "test_primary_health_check_id" {
  description = "Test primary health check ID"
  value       = module.dns_health_test.primary_health_check_id
}

output "test_backup_health_check_id" {
  description = "Test backup health check ID"
  value       = module.dns_health_test.backup_health_check_id
}

output "test_primary_record_fqdn" {
  description = "Test primary DNS record FQDN"
  value       = module.dns_health_test.primary_record_fqdn
}

output "test_backup_record_fqdn" {
  description = "Test backup DNS record FQDN"
  value       = module.dns_health_test.backup_record_fqdn
}

output "test_simple_record_fqdn" {
  description = "Test simple DNS record FQDN"
  value       = module.dns_health_simple_test.primary_record_fqdn
}

output "test_hosted_zone_id" {
  description = "Test hosted zone ID"
  value       = aws_route53_zone.test.zone_id
}

output "test_hosted_zone_name_servers" {
  description = "Test hosted zone name servers"
  value       = aws_route53_zone.test.name_servers
}

output "test_module_summaries" {
  description = "Test module configuration summaries"
  value = {
    health_check = module.dns_health_test.module_summary
    simple       = module.dns_health_simple_test.module_summary
  }
} 