# DNS Health Check Module Customization Guide

This guide provides comprehensive documentation for customizing the AWS Route 53 Health Checks + Failover Terraform module. The module offers over 50+ configurable parameters to meet various use cases and requirements.

## Table of Contents

1. [Basic Configuration](#basic-configuration)
2. [Health Check Configuration](#health-check-configuration)
3. [DNS Configuration](#dns-configuration)
4. [Routing Policies](#routing-policies)
5. [Hosted Zone Configuration](#hosted-zone-configuration)
6. [CloudWatch Alarms Configuration](#cloudwatch-alarms-configuration)
7. [SNS Notifications Configuration](#sns-notifications-configuration)
8. [Usage Examples](#usage-examples)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

## Basic Configuration

### Core Parameters

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `name_prefix` | string | `"dns-health"` | Prefix for all resource names |
| `environment` | string | `"dev"` | Environment name (dev, staging, prod, test) |
| `primary_endpoint` | string | **Required** | Primary endpoint FQDN or IP address |
| `backup_endpoint` | string | `null` | Backup endpoint FQDN or IP address |
| `tags` | map(string) | `{}` | Tags to apply to all resources |

**Example:**
```hcl
module "dns_health" {
  source = "./tfm-aws-dns-health"

  name_prefix       = "my-app"
  environment      = "prod"
  primary_endpoint  = "primary.example.com"
  backup_endpoint   = "backup.example.com"
  
  tags = {
    Project     = "My Application"
    Environment = "prod"
    Owner       = "DevOps Team"
    CostCenter  = "IT-001"
  }
}
```

## Health Check Configuration

### Basic Health Check Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_health_checks` | bool | `true` | Enable Route 53 health checks |
| `health_check_type` | string | `"HTTP"` | Type of health check |
| `health_check_port` | number | `80` | Port for health check |
| `health_check_path` | string | `"/"` | Path for HTTP/HTTPS health checks |
| `health_check_timeout` | number | `5` | Timeout for health check in seconds |
| `failure_threshold` | number | `3` | Consecutive failures before marking unhealthy |
| `request_interval` | number | `30` | Time between health check requests |

**Health Check Types:**
- `HTTP`: Standard HTTP health checks
- `HTTPS`: Secure HTTPS health checks
- `TCP`: TCP connection health checks
- `HTTP_STR_MATCH`: HTTP with string matching
- `HTTPS_STR_MATCH`: HTTPS with string matching
- `CALCULATED`: Calculated health checks
- `CLOUDWATCH_METRIC`: CloudWatch metric-based health checks

**Example:**
```hcl
# Basic HTTP health check
health_check_type = "HTTP"
health_check_port = 80
health_check_path = "/health"
health_check_timeout = 5
failure_threshold = 3
request_interval = 30

# Advanced HTTPS health check
health_check_type = "HTTPS"
health_check_port = 443
health_check_path = "/api/health"
health_check_timeout = 8
failure_threshold = 2
request_interval = 10
```

### Advanced Health Check Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `health_check_search_string` | string | `null` | String to search for in response body |
| `invert_healthcheck` | bool | `false` | Invert the health check status |
| `measure_latency` | bool | `false` | Measure latency for health checks |
| `health_check_regions` | list(string) | `["us-east-1"]` | List of regions to perform health checks from |
| `enable_sni` | bool | `false` | Enable Server Name Indication for HTTPS |
| `insufficient_data_health_status` | string | `null` | Health status when insufficient data |
| `child_healthchecks` | list(string) | `[]` | List of child health check IDs |
| `child_health_threshold` | number | `1` | Number of child health checks that must be healthy |

**Example:**
```hcl
# Advanced health check with string matching
health_check_search_string = "healthy"
measure_latency = true
health_check_regions = ["us-east-1", "us-west-2", "eu-west-1"]
enable_sni = true
insufficient_data_health_status = "LastKnownStatus"

# Calculated health check
child_healthchecks = [
  "hc-1234567890abcdef0",
  "hc-0987654321fedcba0"
]
child_health_threshold = 2
```

## DNS Configuration

### Basic DNS Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `record_name` | string | `"api"` | DNS record name |
| `record_type` | string | `"A"` | DNS record type |
| `ttl` | number | `300` | Time to live for DNS records in seconds |
| `evaluate_target_health` | bool | `true` | Evaluate target health for alias records |
| `alias_zone_id` | string | `null` | Zone ID for alias records |

**Record Types:**
- `A`: IPv4 address record
- `AAAA`: IPv6 address record
- `CNAME`: Canonical name record
- `TXT`: Text record
- `MX`: Mail exchange record
- `NS`: Name server record

**Example:**
```hcl
# Basic A record
record_name = "api"
record_type = "A"
ttl = 300
evaluate_target_health = true

# Alias record for ALB
alias_zone_id = "Z35SXDOTRQ7X7K" # ALB zone ID
```

## Routing Policies

The module supports multiple routing policies. Only one routing policy should be used per record.

### Failover Routing (Default)
Automatically configured when health checks are enabled.

### Latency-Based Routing

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `latency_routing_region` | string | `null` | Region for latency-based routing |

**Example:**
```hcl
latency_routing_region = "us-east-1"
```

### Geolocation-Based Routing

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `geolocation_continent` | string | `null` | Continent for geolocation routing |
| `geolocation_country` | string | `null` | Country for geolocation routing |
| `geolocation_subdivision` | string | `null` | Subdivision for geolocation routing |

**Example:**
```hcl
# Route to North America
geolocation_continent = "NA"

# Route to specific country
geolocation_country = "US"

# Route to specific state
geolocation_subdivision = "CA"
```

### Weighted Routing

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `weighted_routing_weight` | number | `1` | Weight for weighted routing (0-255) |

**Example:**
```hcl
weighted_routing_weight = 100
```

### Multivalue Answer Routing

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `multivalue_answer_routing_policy` | bool | `false` | Enable multivalue answer routing |

**Example:**
```hcl
multivalue_answer_routing_policy = true
```

## Hosted Zone Configuration

### Basic Hosted Zone Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `create_hosted_zone` | bool | `false` | Create a new Route 53 hosted zone |
| `domain_name` | string | `null` | Domain name for hosted zone |
| `hosted_zone_id` | string | `null` | Existing Route 53 hosted zone ID |

### Advanced Hosted Zone Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `hosted_zone_comment` | string | `"Managed by Terraform"` | Comment for the hosted zone |
| `hosted_zone_force_destroy` | bool | `false` | Force destroy the hosted zone |
| `hosted_zone_delegation_set_id` | string | `null` | Delegation set ID for the hosted zone |

**Example:**
```hcl
# Create new hosted zone
create_hosted_zone = true
domain_name = "example.com"
hosted_zone_comment = "Production hosted zone"
hosted_zone_force_destroy = false

# Use existing hosted zone
create_hosted_zone = false
hosted_zone_id = "Z1234567890ABC"
```

## CloudWatch Alarms Configuration

### Basic Alarm Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_cloudwatch_alarms` | bool | `true` | Enable CloudWatch alarms |
| `alarm_comparison_operator` | string | `"LessThanThreshold"` | Comparison operator |
| `alarm_evaluation_periods` | number | `2` | Number of evaluation periods |
| `alarm_metric_name` | string | `"HealthCheckStatus"` | Metric name |
| `alarm_namespace` | string | `"AWS/Route53"` | Namespace |
| `alarm_period` | number | `60` | Period in seconds |
| `alarm_statistic` | string | `"Average"` | Statistic |
| `alarm_threshold` | number | `1.0` | Threshold |
| `alarm_description` | string | `"Health check failure alarm"` | Description |

### Advanced Alarm Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `alarm_actions` | list(string) | `[]` | List of ARNs for alarm actions |
| `ok_actions` | list(string) | `[]` | List of ARNs for OK actions |
| `insufficient_data_actions` | list(string) | `[]` | List of ARNs for insufficient data actions |
| `treat_missing_data` | string | `"missing"` | How to treat missing data |
| `datapoints_to_alarm` | number | `null` | Number of datapoints to alarm |
| `extended_statistic` | string | `null` | Extended statistic |
| `alarm_unit` | string | `null` | Unit for alarms |

**Comparison Operators:**
- `GreaterThanOrEqualToThreshold`
- `GreaterThanThreshold`
- `LessThanThreshold`
- `LessThanOrEqualToThreshold`

**Statistics:**
- `SampleCount`
- `Average`
- `Sum`
- `Minimum`
- `Maximum`

**Treat Missing Data Options:**
- `missing`
- `notBreaching`
- `breaching`
- `ignore`

**Example:**
```hcl
# Basic alarm configuration
enable_cloudwatch_alarms = true
alarm_comparison_operator = "LessThanThreshold"
alarm_evaluation_periods = 2
alarm_period = 60
alarm_threshold = 1.0

# Advanced alarm configuration
alarm_actions = [
  "arn:aws:sns:us-east-1:123456789012:ops-alerts",
  "arn:aws:sns:us-east-1:123456789012:pager-duty"
]
ok_actions = [
  "arn:aws:sns:us-east-1:123456789012:ops-resolved"
]
treat_missing_data = "notBreaching"
datapoints_to_alarm = 1
```

## SNS Notifications Configuration

### Basic SNS Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_sns_notifications` | bool | `false` | Enable SNS notifications |
| `notification_email` | string | `null` | Email address for notifications |

### Advanced SNS Topic Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `sns_topic_display_name` | string | `null` | Display name for SNS topic |
| `sns_topic_kms_key_id` | string | `null` | KMS key ID for encryption |
| `sns_topic_fifo` | bool | `false` | Enable FIFO topic |
| `sns_topic_content_based_deduplication` | bool | `false` | Enable content-based deduplication |

### SNS Subscription Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `sns_subscription_confirmation_timeout` | number | `1` | Confirmation timeout in minutes |
| `sns_subscription_delivery_policy` | string | `null` | Delivery policy |
| `sns_subscription_filter_policy` | string | `null` | Filter policy |
| `sns_subscription_filter_policy_scope` | string | `null` | Filter policy scope |
| `sns_subscription_raw_message_delivery` | bool | `false` | Enable raw message delivery |
| `sns_subscription_redrive_policy` | string | `null` | Redrive policy |
| `sns_subscription_role_arn` | string | `null` | IAM role ARN |

**Filter Policy Scope Options:**
- `MessageAttributes`
- `MessageBody`

**Example:**
```hcl
# Basic SNS configuration
enable_sns_notifications = true
notification_email = "ops@example.com"

# Advanced SNS configuration
sns_topic_display_name = "Health Check Alerts"
sns_topic_kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
sns_topic_fifo = false
sns_subscription_confirmation_timeout = 5
sns_subscription_raw_message_delivery = false
```

## Usage Examples

### Minimal Configuration

```hcl
module "dns_health_minimal" {
  source = "./tfm-aws-dns-health"

  name_prefix       = "minimal"
  primary_endpoint  = "primary.example.com"
  backup_endpoint   = "backup.example.com"
  
  # Use existing hosted zone
  create_hosted_zone = false
  hosted_zone_id     = "Z1234567890ABC"
}
```

### Production Configuration

```hcl
module "dns_health_production" {
  source = "./tfm-aws-dns-health"

  name_prefix       = "prod-app"
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
  
  # SNS notifications
  enable_sns_notifications = true
  notification_email = "ops@example.com"
  sns_topic_display_name = "Production Health Alerts"
  
  tags = {
    Project     = "Production Application"
    Environment = "prod"
    Owner       = "SRE Team"
    CostCenter  = "IT-001"
    Compliance  = "SOX"
  }
}
```

### Development Configuration

```hcl
module "dns_health_development" {
  source = "./tfm-aws-dns-health"

  name_prefix       = "dev-app"
  environment      = "dev"
  primary_endpoint  = "dev-primary.example.com"
  
  # Simple health check
  health_check_type = "HTTP"
  health_check_port = 80
  health_check_path = "/health"
  
  # DNS configuration
  record_name = "api"
  record_type = "A"
  
  # Use existing hosted zone
  create_hosted_zone = false
  hosted_zone_id     = "Z1234567890ABC"
  
  # Basic monitoring
  enable_cloudwatch_alarms = true
  enable_sns_notifications = false
  
  tags = {
    Project     = "Development Application"
    Environment = "dev"
    Owner       = "Dev Team"
  }
}
```

## Best Practices

### Health Check Configuration

1. **Choose Appropriate Health Check Type:**
   - Use `HTTP` for basic web services
   - Use `HTTPS` for secure services
   - Use `TCP` for non-HTTP services
   - Use `HTTP_STR_MATCH` or `HTTPS_STR_MATCH` for content validation

2. **Optimize Health Check Parameters:**
   - Use 30-second intervals for production (10-second for critical systems)
   - Set appropriate failure thresholds (2-3 for production)
   - Configure reasonable timeouts (5-10 seconds)

3. **Multi-Region Health Checks:**
   - Use multiple regions for global applications
   - Consider latency between regions
   - Balance cost vs. coverage

### DNS Configuration

1. **TTL Settings:**
   - Use low TTL (60-300 seconds) for fast failover
   - Use higher TTL (3600+ seconds) for stable services

2. **Routing Policies:**
   - Use failover routing for disaster recovery
   - Use latency-based routing for global applications
   - Use geolocation routing for regional services

### Monitoring and Alerting

1. **CloudWatch Alarms:**
   - Set appropriate evaluation periods
   - Configure meaningful thresholds
   - Use multiple alarm actions for redundancy

2. **SNS Notifications:**
   - Use FIFO topics for ordered notifications
   - Implement filter policies for targeted alerts
   - Configure proper delivery policies

### Security

1. **Encryption:**
   - Use HTTPS health checks for sensitive services
   - Enable KMS encryption for SNS topics
   - Use SNI for HTTPS health checks

2. **Access Control:**
   - Implement proper IAM policies
   - Use least privilege principle
   - Monitor access logs

## Troubleshooting

### Common Issues

1. **Health Check Failures:**
   - Verify endpoint accessibility
   - Check firewall and security group rules
   - Validate health check path and port
   - Review health check timeout settings

2. **DNS Resolution Issues:**
   - Confirm hosted zone configuration
   - Verify name server delegation
   - Check record propagation
   - Review TTL settings

3. **CloudWatch Alarm Issues:**
   - Validate alarm configuration
   - Check SNS topic permissions
   - Verify email subscription
   - Review alarm thresholds

4. **SNS Notification Issues:**
   - Confirm topic creation
   - Verify subscription confirmation
   - Check delivery policies
   - Review filter policies

### Debug Commands

```bash
# Check health check status
aws route53 get-health-check --health-check-id <health-check-id>

# Verify DNS records
aws route53 list-resource-record-sets --hosted-zone-id <zone-id>

# Check CloudWatch alarms
aws cloudwatch describe-alarms --alarm-names <alarm-name>

# Verify SNS topic
aws sns get-topic-attributes --topic-arn <topic-arn>

# Test health check endpoint
curl -I https://your-endpoint.com/health
```

### Performance Optimization

1. **Health Check Optimization:**
   - Use appropriate request intervals
   - Optimize health check endpoints
   - Consider calculated health checks for complex scenarios

2. **DNS Optimization:**
   - Use appropriate TTL values
   - Implement caching strategies
   - Consider using Route 53 Resolver

3. **Monitoring Optimization:**
   - Use appropriate alarm periods
   - Implement metric filtering
   - Consider custom metrics

This customization guide provides comprehensive information for configuring the DNS Health Check module. For additional examples and use cases, refer to the `examples/` directory in the module repository. 