# AWS Route 53 Health Checks + Failover Terraform Module

A comprehensive Terraform module for implementing Route 53 health checks with automatic failover capabilities. This module provides robust DNS-based disaster recovery and high availability solutions for AWS workloads.

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

## ✨ Features

- **Health Check Monitoring**: HTTP/HTTPS/TCP health checks with customizable parameters
- **Automatic Failover**: Route 53 failover routing policy for disaster recovery
- **CloudWatch Integration**: Automated alarms and monitoring
- **SNS Notifications**: Email and topic-based alerting
- **Flexible Configuration**: Support for existing or new hosted zones
- **Multi-Environment Support**: Dev, staging, and production configurations
- **Comprehensive Tagging**: Resource tagging for cost management and compliance

## 🚀 Use Cases

- **Disaster Recovery**: Automatic failover between primary and backup regions
- **Multi-Region Applications**: Geographic redundancy and load distribution
- **High Availability**: Zero-downtime failover for critical services
- **Monitoring & Alerting**: Proactive health monitoring with notifications
- **Compliance**: Audit trails and monitoring for regulatory requirements

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## 🔧 Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## 📦 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names | `string` | `"dns-health"` | no |
| environment | Environment name (dev, staging, prod, test) | `string` | `"dev"` | no |
| primary_endpoint | Primary endpoint FQDN or IP address | `string` | n/a | yes |
| backup_endpoint | Backup endpoint FQDN or IP address (optional) | `string` | `null` | no |
| enable_health_checks | Enable Route 53 health checks | `bool` | `true` | no |
| health_check_type | Type of health check | `string` | `"HTTP"` | no |
| health_check_port | Port for health check | `number` | `80` | no |
| health_check_path | Path for HTTP/HTTPS health checks | `string` | `"/"` | no |
| failure_threshold | Consecutive failures before marking unhealthy | `number` | `3` | no |
| request_interval | Time between health check requests (seconds) | `number` | `30` | no |
| timeout | Response timeout (seconds) | `number` | `5` | no |
| create_hosted_zone | Create a new Route 53 hosted zone | `bool` | `false` | no |
| domain_name | Domain name for hosted zone | `string` | `null` | no |
| hosted_zone_id | Existing Route 53 hosted zone ID | `string` | `null` | no |
| record_name | DNS record name | `string` | `"api"` | no |
| record_type | DNS record type | `string` | `"A"` | no |
| alias_zone_id | Zone ID for alias records | `string` | `null` | no |
| ttl | Time to live for DNS records (seconds) | `number` | `300` | no |
| enable_cloudwatch_alarms | Enable CloudWatch alarms | `bool` | `true` | no |
| alarm_evaluation_periods | CloudWatch alarm evaluation periods | `number` | `2` | no |
| alarm_period | CloudWatch alarm period (seconds) | `number` | `60` | no |
| alarm_actions | CloudWatch alarm action ARNs | `list(string)` | `[]` | no |
| ok_actions | CloudWatch OK action ARNs | `list(string)` | `[]` | no |
| enable_sns_notifications | Enable SNS notifications | `bool` | `false` | no |
| notification_email | Email for SNS notifications | `string` | `null` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

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
| health_check_status | Current status of health checks |
| module_summary | Summary of the module configuration |

## 🛠️ Usage

### Basic Example

```hcl
module "dns_health" {
  source = "./tfm-aws-dns-health"

  name_prefix       = "myapp"
  environment      = "prod"
  primary_endpoint  = "primary-api.example.com"
  backup_endpoint   = "backup-api.example.com"
  
  health_check_type = "HTTPS"
  health_check_port = 443
  health_check_path = "/health"
  
  record_name = "api"
  
  create_hosted_zone = false
  hosted_zone_id     = "Z1234567890ABC"
  
  enable_cloudwatch_alarms = true
  enable_sns_notifications = true
  notification_email       = "ops@example.com"
  
  tags = {
    Project     = "MyApp"
    Environment = "prod"
    Owner       = "DevOps Team"
  }
}
```

### Advanced Example

```hcl
module "dns_health_advanced" {
  source = "./tfm-aws-dns-health"

  name_prefix       = "critical-app"
  environment      = "prod"
  primary_endpoint  = "primary.example.com"
  backup_endpoint   = "backup.example.com"
  
  # Custom health check settings
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
  
  # Advanced monitoring
  enable_cloudwatch_alarms = true
  alarm_evaluation_periods = 3
  alarm_period             = 30
  
  # Custom alarm actions
  alarm_actions = [
    "arn:aws:sns:us-east-1:123456789012:ops-alerts",
    "arn:aws:sns:us-east-1:123456789012:pager-duty"
  ]
  
  # SNS notifications
  enable_sns_notifications = true
  notification_email       = "ops@example.com"
  
  tags = {
    Project     = "Critical Application"
    Environment = "prod"
    Owner       = "SRE Team"
    CostCenter  = "IT-001"
    Compliance  = "SOX"
  }
}
```

### Simple Example (No Health Checks)

```hcl
module "dns_simple" {
  source = "./tfm-aws-dns-health"

  name_prefix       = "simple-app"
  environment      = "dev"
  primary_endpoint  = "simple.example.com"
  
  # Disable health checks
  enable_health_checks = false
  
  record_name = "simple"
  
  create_hosted_zone = false
  hosted_zone_id     = "Z1234567890ABC"
  
  # Disable monitoring
  enable_cloudwatch_alarms = false
  enable_sns_notifications = false
  
  tags = {
    Project     = "Simple App"
    Environment = "dev"
  }
}
```

## 🔍 Health Check Types

The module supports the following health check types:

- **HTTP**: Standard HTTP health checks
- **HTTPS**: Secure HTTPS health checks
- **TCP**: TCP connection health checks
- **HTTP_STR_MATCH**: HTTP with string matching
- **HTTPS_STR_MATCH**: HTTPS with string matching
- **CALCULATED**: Calculated health checks
- **CLOUDWATCH_METRIC**: CloudWatch metric-based health checks

## 📊 Monitoring & Alerting

### CloudWatch Alarms

The module automatically creates CloudWatch alarms for health check failures:

- **Primary Health Check Alarm**: Triggers when primary endpoint becomes unhealthy
- **Backup Health Check Alarm**: Triggers when backup endpoint becomes unhealthy

### SNS Notifications

Optional SNS topic creation with email subscriptions for:

- Health check failures
- Health check recoveries
- Custom alarm actions

## 🔒 Security

### IAM Permissions

The following IAM permissions are required:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:CreateHealthCheck",
        "route53:DeleteHealthCheck",
        "route53:GetHealthCheck",
        "route53:UpdateHealthCheck",
        "route53:CreateHostedZone",
        "route53:DeleteHostedZone",
        "route53:GetHostedZone",
        "route53:CreateResourceRecordSet",
        "route53:DeleteResourceRecordSet",
        "route53:GetResourceRecordSet",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DeleteAlarms",
        "cloudwatch:DescribeAlarms",
        "sns:CreateTopic",
        "sns:DeleteTopic",
        "sns:Subscribe",
        "sns:Unsubscribe"
      ],
      "Resource": "*"
    }
  ]
}
```

### Encryption

- All health check communications use HTTPS when configured
- SNS topics support encryption at rest
- CloudWatch logs are encrypted by default

## 🧪 Testing

### Manual Testing

1. **Health Check Validation**:
   ```bash
   # Test primary endpoint
   curl -I https://primary-api.example.com/health
   
   # Test backup endpoint
   curl -I https://backup-api.example.com/health
   ```

2. **DNS Resolution**:
   ```bash
   # Check DNS resolution
   nslookup api.example.com
   dig api.example.com
   ```

3. **Failover Testing**:
   ```bash
   # Simulate primary failure
   # Verify automatic failover to backup
   ```

### Automated Testing

The module includes example configurations for testing:

```bash
# Navigate to examples
cd examples/basic

# Initialize and plan
terraform init
terraform plan

# Apply (use with caution)
terraform apply
```

## 📈 Performance Considerations

- **Health Check Intervals**: Use 30-second intervals for production (10-second for critical systems)
- **Failure Thresholds**: Balance between responsiveness and stability
- **DNS TTL**: Consider lower TTL values for faster failover
- **Monitoring**: Use CloudWatch alarms for proactive monitoring

## 💰 Cost Optimization

- **Health Check Pricing**: Route 53 health checks are charged per check per month
- **CloudWatch Alarms**: Standard CloudWatch pricing applies
- **SNS Notifications**: Pay per message delivered
- **Hosted Zones**: Monthly charge per hosted zone

## 🚨 Troubleshooting

### Common Issues

1. **Health Check Failures**:
   - Verify endpoint accessibility
   - Check firewall rules
   - Validate health check path

2. **DNS Resolution Issues**:
   - Confirm hosted zone configuration
   - Verify name server delegation
   - Check record propagation

3. **CloudWatch Alarm Issues**:
   - Validate alarm configuration
   - Check SNS topic permissions
   - Verify email subscription

### Debug Commands

```bash
# Check health check status
aws route53 get-health-check --health-check-id <health-check-id>

# Verify DNS records
aws route53 list-resource-record-sets --hosted-zone-id <zone-id>

# Check CloudWatch alarms
aws cloudwatch describe-alarms --alarm-names <alarm-name>
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This module is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:

- Create an issue in the repository
- Review the examples directory
- Check the troubleshooting section
- Consult AWS Route 53 documentation

## 🔄 Version History

- **v1.0.0**: Initial release with basic health check functionality
- **v1.1.0**: Added CloudWatch alarms and SNS notifications
- **v1.2.0**: Enhanced validation and error handling
- **v1.3.0**: Added support for multiple health check types
- **v1.4.0**: Improved documentation and examples

---

**Note**: This module is designed for production use but should be thoroughly tested in your environment before deployment.