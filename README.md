# AWS Route 53 Health Checks + Failover Terraform Module

A comprehensive Terraform module for implementing Route 53 health checks with automatic failover capabilities. This module provides robust DNS-based disaster recovery and high availability solutions for AWS workloads with extensive customization options.

## 🏗️ Architecture

```
Primary Endpoint ← Route 53 Health Checks → Backup Endpoint
                     ↓
              Automatic DNS Updates
                     ↓
              CloudWatch Monitoring
                     ↓
              SNS Notifications
```

## 📋 Resource Map

This module creates the following AWS resources:

### Route 53 Resources
| Resource | Type | Purpose | Conditional |
|----------|------|---------|-------------|
| `aws_route53_health_check.primary` | Route 53 Health Check | Primary endpoint health monitoring | `enable_health_checks = true` |
| `aws_route53_health_check.backup` | Route 53 Health Check | Backup endpoint health monitoring | `enable_health_checks = true && backup_endpoint != null` |
| `aws_route53_zone.main` | Route 53 Hosted Zone | DNS zone for domain management | `create_hosted_zone = true` |
| `aws_route53_record.primary` | Route 53 Record | Primary DNS record with failover | `enable_health_checks = true` |
| `aws_route53_record.backup` | Route 53 Record | Backup DNS record with failover | `enable_health_checks = true && backup_endpoint != null` |
| `aws_route53_record.simple` | Route 53 Record | Simple DNS record without health checks | `enable_health_checks = false` |

### CloudWatch Resources
| Resource | Type | Purpose | Conditional |
|----------|------|---------|-------------|
| `aws_cloudwatch_metric_alarm.primary_health` | CloudWatch Alarm | Primary health check monitoring | `enable_cloudwatch_alarms = true && enable_health_checks = true` |
| `aws_cloudwatch_metric_alarm.backup_health` | CloudWatch Alarm | Backup health check monitoring | `enable_cloudwatch_alarms = true && enable_health_checks = true && backup_endpoint != null` |

### SNS Resources
| Resource | Type | Purpose | Conditional |
|----------|------|---------|-------------|
| `aws_sns_topic.health_notifications` | SNS Topic | Health check notification topic | `enable_sns_notifications = true` |
| `aws_sns_topic_policy.health_notifications` | SNS Topic Policy | Topic access policy | `enable_sns_notifications = true` |
| `aws_sns_topic_subscription.email` | SNS Subscription | Email notification subscription | `enable_sns_notifications = true && notification_email != null` |

### Resource Dependencies
```
Route 53 Health Checks
    ↓
Route 53 Records (with failover routing)
    ↓
CloudWatch Alarms (monitoring health check status)
    ↓
SNS Notifications (alerting on failures)
```

## ✨ Features

- **Advanced Health Check Monitoring**: HTTP/HTTPS/TCP health checks with extensive customization
  - Custom timeout, search strings, and latency measurement
  - Multi-region health checks and SNI support
  - Calculated health checks with child health check support
  - Inverted health checks and insufficient data handling
- **Flexible Routing Policies**: Support for failover, latency-based, geolocation, and weighted routing
- **Automatic Failover**: Route 53 failover routing policy for disaster recovery
- **Enhanced CloudWatch Integration**: Comprehensive alarm configuration with custom thresholds and actions
- **Advanced SNS Notifications**: FIFO topics, KMS encryption, and subscription filtering
- **Flexible DNS Configuration**: Support for existing or new hosted zones with delegation sets
- **Multi-Environment Support**: Dev, staging, and production configurations
- **Comprehensive Tagging**: Resource tagging for cost management and compliance
- **Extensive Customization**: Over 50+ configurable parameters for maximum flexibility

## 🚀 Use Cases

- **Disaster Recovery**: Automatic failover between primary and backup regions
- **Multi-Region Applications**: Geographic redundancy and load distribution
- **High Availability**: Zero-downtime failover for critical services
- **Advanced Monitoring & Alerting**: Proactive health monitoring with custom notifications
- **Compliance**: Audit trails and monitoring for regulatory requirements
- **Global Load Balancing**: Latency-based and geolocation routing
- **Microservices Health**: Complex health check scenarios with calculated checks

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.13.0 |
| aws | ~> 6.2.0 |
| terragrunt | ~> 0.84.0 |

## 🔧 Providers

| Name | Version |
|------|---------|
| aws | ~> 6.2.0 |

## 📦 Inputs

### Basic Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names | `string` | `"dns-health"` | no |
| environment | Environment name (dev, staging, prod, test) | `string` | `"dev"` | no |
| primary_endpoint | Primary endpoint FQDN or IP address | `string` | n/a | yes |
| backup_endpoint | Backup endpoint FQDN or IP address (optional) | `string` | `null` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

### Health Check Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_health_checks | Enable Route 53 health checks | `bool` | `true` | no |
| health_check_type | Type of health check (HTTP, HTTPS, TCP, HTTP_STR_MATCH, HTTPS_STR_MATCH, CALCULATED, CLOUDWATCH_METRIC) | `string` | `"HTTP"` | no |
| health_check_port | Port for health check | `number` | `80` | no |
| health_check_path | Path for HTTP/HTTPS health checks | `string` | `"/"` | no |
| health_check_timeout | Timeout for health check in seconds | `number` | `5` | no |
| health_check_search_string | String to search for in response body | `string` | `null` | no |
| invert_healthcheck | Invert the health check status | `bool` | `false` | no |
| measure_latency | Measure latency for health checks | `bool` | `false` | no |
| health_check_regions | List of regions to perform health checks from | `list(string)` | `["us-east-1"]` | no |
| enable_sni | Enable Server Name Indication for HTTPS health checks | `bool` | `false` | no |
| insufficient_data_health_status | Health status when insufficient data (Healthy, Unhealthy, LastKnownStatus) | `string` | `null` | no |
| failure_threshold | Consecutive failures before marking unhealthy | `number` | `3` | no |
| request_interval | Time between health check requests (seconds) | `number` | `30` | no |
| child_healthchecks | List of child health check IDs for calculated health checks | `list(string)` | `[]` | no |
| child_health_threshold | Number of child health checks that must be healthy | `number` | `1` | no |

### DNS Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| record_name | DNS record name | `string` | `"api"` | no |
| record_type | DNS record type (A, AAAA, CNAME, TXT, MX, NS) | `string` | `"A"` | no |
| ttl | Time to live for DNS records (seconds) | `number` | `300` | no |
| evaluate_target_health | Evaluate target health for alias records | `bool` | `true` | no |
| alias_zone_id | Zone ID for alias records (ALB, CloudFront, etc.) | `string` | `null` | no |

### Routing Policies

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| latency_routing_region | Region for latency-based routing | `string` | `null` | no |
| geolocation_continent | Continent for geolocation-based routing | `string` | `null` | no |
| geolocation_country | Country for geolocation-based routing | `string` | `null` | no |
| geolocation_subdivision | Subdivision for geolocation-based routing | `string` | `null` | no |
| weighted_routing_weight | Weight for weighted routing | `number` | `1` | no |
| multivalue_answer_routing_policy | Enable multivalue answer routing policy | `bool` | `false` | no |

### Hosted Zone Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_hosted_zone | Create a new Route 53 hosted zone | `bool` | `false` | no |
| domain_name | Domain name for hosted zone | `string` | `null` | no |
| hosted_zone_id | Existing Route 53 hosted zone ID | `string` | `null` | no |
| hosted_zone_comment | Comment for the hosted zone | `string` | `"Managed by Terraform"` | no |
| hosted_zone_force_destroy | Force destroy the hosted zone even if it contains records | `bool` | `false` | no |
| hosted_zone_delegation_set_id | Delegation set ID for the hosted zone | `string` | `null` | no |

### CloudWatch Alarms Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_cloudwatch_alarms | Enable CloudWatch alarms for health check failures | `bool` | `true` | no |
| alarm_comparison_operator | Comparison operator for CloudWatch alarms | `string` | `"LessThanThreshold"` | no |
| alarm_evaluation_periods | Number of evaluation periods for CloudWatch alarms | `number` | `2` | no |
| alarm_metric_name | Metric name for CloudWatch alarms | `string` | `"HealthCheckStatus"` | no |
| alarm_namespace | Namespace for CloudWatch alarms | `string` | `"AWS/Route53"` | no |
| alarm_period | Period for CloudWatch alarms in seconds | `number` | `60` | no |
| alarm_statistic | Statistic for CloudWatch alarms | `string` | `"Average"` | no |
| alarm_threshold | Threshold for CloudWatch alarms | `number` | `1.0` | no |
| alarm_description | Description for CloudWatch alarms | `string` | `"Health check failure alarm"` | no |
| alarm_actions | List of ARNs for CloudWatch alarm actions | `list(string)` | `[]` | no |
| ok_actions | List of ARNs for CloudWatch OK actions | `list(string)` | `[]` | no |
| insufficient_data_actions | List of ARNs for CloudWatch insufficient data actions | `list(string)` | `[]` | no |
| treat_missing_data | How to treat missing data in CloudWatch alarms | `string` | `"missing"` | no |
| datapoints_to_alarm | Number of datapoints that must be breaching to trigger alarm | `number` | `null` | no |
| extended_statistic | Extended statistic for CloudWatch alarms | `string` | `null` | no |
| alarm_unit | Unit for CloudWatch alarms | `string` | `null` | no |

### SNS Notifications Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_sns_notifications | Enable SNS notifications for health check events | `bool` | `false` | no |
| notification_email | Email address for SNS notifications | `string` | `null` | no |
| sns_topic_display_name | Display name for SNS topic | `string` | `null` | no |
| sns_topic_kms_key_id | KMS key ID for SNS topic encryption | `string` | `null` | no |
| sns_topic_fifo | Enable FIFO (First-In-First-Out) for SNS topic | `bool` | `false` | no |
| sns_topic_content_based_deduplication | Enable content-based deduplication for FIFO SNS topic | `bool` | `false` | no |
| sns_subscription_confirmation_timeout | Confirmation timeout in minutes for SNS subscription | `number` | `1` | no |
| sns_subscription_delivery_policy | Delivery policy for SNS subscription | `string` | `null` | no |
| sns_subscription_filter_policy | Filter policy for SNS subscription | `string` | `null` | no |
| sns_subscription_filter_policy_scope | Filter policy scope for SNS subscription | `string` | `null` | no |
| sns_subscription_raw_message_delivery | Enable raw message delivery for SNS subscription | `bool` | `false` | no |
| sns_subscription_redrive_policy | Redrive policy for SNS subscription | `string` | `null` | no |
| sns_subscription_role_arn | IAM role ARN for SNS subscription | `string` | `null` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| primary_health_check_id | ID of the primary health check |
| primary_health_check_arn | ARN of the primary health check |
| backup_health_check_id | ID of the backup health check |
| backup_health_check_arn | ARN of the backup health check |
| hosted_zone_id | ID of the Route 53 hosted zone |
| hosted_zone_name_servers | Name servers of the hosted zone |
| primary_record_name | Name of the primary DNS record |
| primary_record_fqdn | FQDN of the primary DNS record |
| backup_record_name | Name of the backup DNS record |
| backup_record_fqdn | FQDN of the backup DNS record |
| primary_cloudwatch_alarm_arn | ARN of the primary health check CloudWatch alarm |
| backup_cloudwatch_alarm_arn | ARN of the backup health check CloudWatch alarm |
| sns_topic_arn | ARN of the SNS topic for health check notifications |
| sns_topic_name | Name of the SNS topic for health check notifications |
| module_summary | Summary of the module configuration |

## 🛠️ Usage

### Basic Usage

```hcl
module "dns_health" {
  source = "./tfm-aws-dns-health"

  name_prefix       = "my-app"
  environment      = "prod"
  primary_endpoint  = "primary.example.com"
  backup_endpoint   = "backup.example.com"
  
  # Health check configuration
  health_check_type = "HTTPS"
  health_check_port = 443
  health_check_path = "/health"
  
  # DNS configuration
  record_name = "api"
  record_type = "A"
  
  # Use existing hosted zone
  create_hosted_zone = false
  hosted_zone_id     = "Z1234567890ABC"
  
  # Enable monitoring
  enable_cloudwatch_alarms = true
  enable_sns_notifications = true
  notification_email       = "ops@example.com"
  
  tags = {
    Project     = "My Application"
    Environment = "prod"
    Owner       = "DevOps Team"
  }
}
```

### Advanced Usage with Custom Health Checks

```hcl
module "dns_health_advanced" {
  source = "./tfm-aws-dns-health"

  name_prefix       = "advanced-app"
  environment      = "prod"
  primary_endpoint  = "primary.example.com"
  backup_endpoint   = "backup.example.com"
  
  # Advanced health check configuration
  health_check_type = "HTTPS"
  health_check_port = 443
  health_check_path = "/api/health"
  health_check_timeout = 8
  health_check_search_string = "healthy"
  measure_latency = true
  health_check_regions = ["us-east-1", "us-west-2"]
  enable_sni = true
  
  # Aggressive failure detection
  failure_threshold = 2
  request_interval = 10
  
  # DNS configuration
  record_name = "api"
  record_type = "A"
  
  # Use existing hosted zone
  create_hosted_zone = false
  hosted_zone_id     = "Z1234567890ABC"
  
  # Enhanced monitoring
  enable_cloudwatch_alarms = true
  alarm_evaluation_periods = 3
  alarm_period = 30
  alarm_threshold = 0.5
  
  # SNS notifications with custom settings
  enable_sns_notifications = true
  notification_email = "ops@example.com"
  sns_topic_display_name = "Health Check Alerts"
  
  tags = {
    Project     = "Advanced Application"
    Environment = "prod"
    Owner       = "SRE Team"
  }
}
```

### TCP Health Check Example

```hcl
module "dns_health_tcp" {
  source = "./tfm-aws-dns-health"

  name_prefix       = "tcp-app"
  environment      = "staging"
  primary_endpoint  = "tcp-primary.example.com"
  backup_endpoint   = "tcp-backup.example.com"
  
  # TCP health check configuration
  health_check_type = "TCP"
  health_check_port = 22
  health_check_timeout = 5
  measure_latency = true
  
  # DNS configuration
  record_name = "ssh"
  record_type = "A"
  
  # Use existing hosted zone
  create_hosted_zone = false
  hosted_zone_id     = "Z1234567890ABC"
  
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
```

For more examples, see the `examples/` directory:
- `examples/basic/` - Basic usage examples with comprehensive comments
- `examples/advanced/` - Advanced configurations and use cases

## 📚 Examples

See the [examples](./examples/) directory for complete working examples:

- **Basic Example**: Simple health check with failover
- **Advanced Example**: Complex configurations with custom health checks
- **TCP Health Check**: TCP-based health monitoring
- **Multi-Region**: Health checks from multiple AWS regions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the examples directory for usage patterns
- Review the module outputs for available data

## 🔄 Versioning

This module follows [Semantic Versioning](https://semver.org/). For the versions available, see the tags on this repository.