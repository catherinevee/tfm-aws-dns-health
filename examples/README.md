# Examples

This directory contains example configurations for the AWS Route 53 Health Checks + Failover Terraform module.

## 📁 Directory Structure

```
examples/
├── basic/                    # Basic configuration example
│   ├── main.tf              # Basic module usage
│   ├── terraform.tfvars.example  # Example variables
│   └── README.md            # Basic example documentation
├── advanced/                # Advanced configuration example
│   ├── main.tf              # Advanced module usage
│   ├── terraform.tfvars.example  # Example variables
│   └── README.md            # Advanced example documentation
└── README.md                # This file
```

## 🚀 Quick Start

### Basic Example

The basic example demonstrates simple usage of the module with health checks and failover:

```bash
cd examples/basic

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the variables file with your values
# nano terraform.tfvars

# Initialize and plan
terraform init
terraform plan

# Apply (use with caution)
terraform apply
```

### Advanced Example

The advanced example shows more complex configurations with custom settings:

```bash
cd examples/advanced

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the variables file with your values
# nano terraform.tfvars

# Initialize and plan
terraform init
terraform plan

# Apply (use with caution)
terraform apply
```

## 📋 Prerequisites

Before running the examples, ensure you have:

1. **Terraform** (>= 1.0) installed
2. **AWS CLI** configured with appropriate credentials
3. **AWS Route 53** permissions
4. **Domain name** or existing hosted zone

## 🔧 Configuration

### Required Variables

- `primary_endpoint`: Your primary endpoint FQDN or IP
- `hosted_zone_id`: Existing Route 53 hosted zone ID (if not creating new)

### Optional Variables

- `backup_endpoint`: Backup endpoint for failover
- `health_check_type`: Type of health check (HTTP, HTTPS, TCP)
- `enable_cloudwatch_alarms`: Enable CloudWatch monitoring
- `enable_sns_notifications`: Enable SNS notifications

## 🧪 Testing

### Manual Testing

1. **Health Check Validation**:
   ```bash
   # Test primary endpoint
   curl -I https://your-primary-endpoint.com/health
   
   # Test backup endpoint
   curl -I https://your-backup-endpoint.com/health
   ```

2. **DNS Resolution**:
   ```bash
   # Check DNS resolution
   nslookup your-record-name.your-domain.com
   dig your-record-name.your-domain.com
   ```

3. **Failover Testing**:
   ```bash
   # Simulate primary failure
   # Verify automatic failover to backup
   ```

### Automated Testing

Use the Makefile in the root directory:

```bash
# Run basic example
make examples-basic

# Run advanced example
make examples-advanced
```

## 🧹 Cleanup

To destroy the resources created by the examples:

```bash
# Destroy resources
terraform destroy

# Clean up files
make clean
```

## 📊 Monitoring

### CloudWatch Alarms

The examples create CloudWatch alarms for health check failures:

- **Primary Health Check Alarm**: Triggers when primary endpoint becomes unhealthy
- **Backup Health Check Alarm**: Triggers when backup endpoint becomes unhealthy

### SNS Notifications

If enabled, SNS topics are created with email subscriptions for:

- Health check failures
- Health check recoveries

## 🔒 Security Considerations

- **HTTPS Health Checks**: Use HTTPS for production environments
- **IAM Permissions**: Ensure appropriate AWS permissions
- **SNS Encryption**: SNS topics support encryption at rest
- **Access Control**: Use least privilege principle for IAM roles

## 💰 Cost Considerations

- **Route 53 Health Checks**: Charged per check per month
- **CloudWatch Alarms**: Standard CloudWatch pricing
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

## 📚 Additional Resources

- [AWS Route 53 Documentation](https://docs.aws.amazon.com/route53/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Route 53 Health Checks](https://docs.aws.amazon.com/route53/latest/developerguide/health-checks.html)
- [CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html)

## 🤝 Contributing

To add new examples:

1. Create a new directory under `examples/`
2. Include `main.tf` with module configuration
3. Add `terraform.tfvars.example` with example variables
4. Update this README with documentation
5. Test the example thoroughly

## 📄 License

These examples are provided under the same license as the main module (MIT License). 