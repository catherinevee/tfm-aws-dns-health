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

  # Basic Configuration
  name_prefix       = "example-basic" # Default: "dns-health"
  environment      = "dev"           # Default: "dev"
  primary_endpoint  = "primary.example.com"
  backup_endpoint   = "backup.example.com" # Default: null
  
  # Health Check Configuration
  enable_health_checks = true        # Default: true
  health_check_type = "HTTP"         # Default: "HTTP" (options: HTTP, HTTPS, TCP, HTTP_STR_MATCH, HTTPS_STR_MATCH, CALCULATED, CLOUDWATCH_METRIC)
  health_check_port = 80             # Default: 80
  health_check_path = "/health"      # Default: "/"
  health_check_timeout = 5           # Default: 5 (1-10 seconds)
  health_check_search_string = null  # Default: null (string to search in response body)
  invert_healthcheck = false         # Default: false
  measure_latency = false            # Default: false
  health_check_regions = ["us-east-1"] # Default: ["us-east-1"]
  enable_sni = false                 # Default: false (for HTTPS health checks)
  
  # Advanced Health Check Settings
  failure_threshold = 3              # Default: 3 (1-10)
  request_interval = 30              # Default: 30 (10 or 30 seconds)
  insufficient_data_health_status = null # Default: null (Healthy, Unhealthy, LastKnownStatus)
  
  # DNS Configuration
  record_name = "api"                # Default: "api"
  record_type = "A"                  # Default: "A" (options: A, AAAA, CNAME, TXT, MX, NS)
  ttl = 300                          # Default: 300 seconds
  evaluate_target_health = true      # Default: true (for alias records)
  
  # Routing Policies (optional - only one should be used)
  latency_routing_region = null      # Default: null
  geolocation_continent = null       # Default: null
  geolocation_country = null         # Default: null
  geolocation_subdivision = null     # Default: null
  weighted_routing_weight = 1        # Default: 1 (0-255)
  multivalue_answer_routing_policy = false # Default: false
  
  # Hosted Zone Configuration
  create_hosted_zone = false         # Default: false
  hosted_zone_id = "Z1234567890ABC"  # Replace with your hosted zone ID
  hosted_zone_comment = "Managed by Terraform" # Default: "Managed by Terraform"
  hosted_zone_force_destroy = false  # Default: false
  hosted_zone_delegation_set_id = null # Default: null
  
  # Alias Configuration
  alias_zone_id = null               # Default: null (for ALB, CloudFront, etc.)
  
  # CloudWatch Alarms Configuration
  enable_cloudwatch_alarms = true    # Default: true
  alarm_comparison_operator = "LessThanThreshold" # Default: "LessThanThreshold"
  alarm_evaluation_periods = 2       # Default: 2 (1-10)
  alarm_metric_name = "HealthCheckStatus" # Default: "HealthCheckStatus"
  alarm_namespace = "AWS/Route53"    # Default: "AWS/Route53"
  alarm_period = 60                  # Default: 60 seconds (10-86400)
  alarm_statistic = "Average"        # Default: "Average"
  alarm_threshold = 1.0              # Default: 1.0
  alarm_description = "Health check failure alarm" # Default: "Health check failure alarm"
  alarm_actions = []                 # Default: [] (list of SNS topic ARNs)
  ok_actions = []                    # Default: [] (list of SNS topic ARNs)
  insufficient_data_actions = []     # Default: []
  treat_missing_data = "missing"     # Default: "missing"
  datapoints_to_alarm = null         # Default: null
  extended_statistic = null          # Default: null
  alarm_unit = null                  # Default: null
  
  # SNS Notifications Configuration
  enable_sns_notifications = true    # Default: false
  notification_email = "admin@example.com" # Default: null
  sns_topic_display_name = null      # Default: null
  sns_topic_kms_key_id = null        # Default: null
  sns_topic_fifo = false             # Default: false
  sns_topic_content_based_deduplication = false # Default: false
  
  # SNS Subscription Configuration
  sns_subscription_confirmation_timeout = 1 # Default: 1 minute (1-20)
  sns_subscription_delivery_policy = null    # Default: null
  sns_subscription_filter_policy = null      # Default: null
  sns_subscription_filter_policy_scope = null # Default: null
  sns_subscription_raw_message_delivery = false # Default: false
  sns_subscription_redrive_policy = null     # Default: null
  sns_subscription_role_arn = null           # Default: null
  
  # Tags
  tags = {
    Project     = "DNS Health Check Example"
    Environment = "dev"
    Owner       = "DevOps Team"
    CostCenter  = "IT-001"
    Compliance  = "SOX"
  }
}

# Advanced Configuration Example with Calculated Health Checks
module "dns_health_advanced" {
  source = "../../"

  name_prefix       = "example-advanced"
  environment      = "prod"
  primary_endpoint  = "advanced-primary.example.com"
  backup_endpoint   = "advanced-backup.example.com"
  
  # Advanced Health Check Configuration
  health_check_type = "HTTPS"        # Using HTTPS for secure endpoints
  health_check_port = 443            # HTTPS port
  health_check_path = "/api/health"  # Custom health endpoint
  health_check_timeout = 8           # Longer timeout for complex checks
  health_check_search_string = "healthy" # Search for "healthy" in response
  measure_latency = true             # Enable latency measurement
  health_check_regions = ["us-east-1", "us-west-2"] # Multi-region checks
  enable_sni = true                  # Enable SNI for HTTPS
  
  # Aggressive failure detection
  failure_threshold = 2              # Fail faster
  request_interval = 10              # Check more frequently
  
  # DNS Configuration
  record_name = "api"
  record_type = "A"
  
  # Use existing hosted zone
  create_hosted_zone = false
  hosted_zone_id = "Z1234567890ABC"
  
  # Enhanced monitoring
  enable_cloudwatch_alarms = true
  alarm_evaluation_periods = 3       # More evaluation periods
  alarm_period = 30                  # Shorter alarm period
  alarm_threshold = 0.5              # More sensitive threshold
  
  # SNS notifications with custom settings
  enable_sns_notifications = true
  notification_email = "ops@example.com"
  sns_topic_display_name = "Health Check Alerts"
  sns_subscription_confirmation_timeout = 5 # Longer confirmation timeout
  
  tags = {
    Project     = "Advanced DNS Health Check"
    Environment = "prod"
    Owner       = "SRE Team"
    CostCenter  = "IT-002"
    Compliance  = "PCI"
  }
}

# TCP Health Check Example
module "dns_health_tcp" {
  source = "../../"

  name_prefix       = "example-tcp"
  environment      = "staging"
  primary_endpoint  = "tcp-primary.example.com"
  backup_endpoint   = "tcp-backup.example.com"
  
  # TCP health check configuration
  health_check_type = "TCP"          # TCP health check
  health_check_port = 22             # SSH port example
  health_check_timeout = 5           # TCP timeout
  measure_latency = true             # Measure TCP latency
  
  # DNS configuration
  record_name = "ssh"
  record_type = "A"
  
  # Use existing hosted zone
  create_hosted_zone = false
  hosted_zone_id = "Z1234567890ABC"
  
  # Basic monitoring
  enable_cloudwatch_alarms = true
  enable_sns_notifications = true
  notification_email = "admin@example.com"
  
  tags = {
    Project     = "TCP Health Check"
    Environment = "staging"
    Owner       = "Infrastructure Team"
  }
}

# Output the results
output "basic_primary_health_check_id" {
  description = "Basic primary health check ID"
  value       = module.dns_health_basic.primary_health_check_id
}

output "basic_backup_health_check_id" {
  description = "Basic backup health check ID"
  value       = module.dns_health_basic.backup_health_check_id
}

output "basic_primary_record_fqdn" {
  description = "Basic primary DNS record FQDN"
  value       = module.dns_health_basic.primary_record_fqdn
}

output "basic_backup_record_fqdn" {
  description = "Basic backup DNS record FQDN"
  value       = module.dns_health_basic.backup_record_fqdn
}

output "basic_sns_topic_arn" {
  description = "Basic SNS topic ARN for notifications"
  value       = module.dns_health_basic.sns_topic_arn
}

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

output "tcp_primary_health_check_id" {
  description = "TCP primary health check ID"
  value       = module.dns_health_tcp.primary_health_check_id
}

output "tcp_backup_health_check_id" {
  description = "TCP backup health check ID"
  value       = module.dns_health_tcp.backup_health_check_id
}

output "module_summaries" {
  description = "Summary of all module configurations"
  value = {
    basic     = module.dns_health_basic.module_summary
    advanced  = module.dns_health_advanced.module_summary
    tcp       = module.dns_health_tcp.module_summary
  }
} 