# Route 53 Health Checks + Failover Module Variables

variable "name_prefix" {
  description = "Prefix for resource names. Must contain only lowercase letters, numbers, and hyphens."
  type        = string
  default     = "dns-health"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "Name prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "primary_endpoint" {
  description = "Primary endpoint FQDN or IP address. Must be a valid domain name or IP address."
  type        = string

  validation {
    condition     = var.primary_endpoint != null && var.primary_endpoint != ""
    error_message = "Primary endpoint is required and cannot be empty."
  }
}

variable "backup_endpoint" {
  description = "Backup endpoint FQDN or IP address (optional). Must be a valid domain name or IP address."
  type        = string
  default     = null

  validation {
    condition     = var.backup_endpoint == null || (var.backup_endpoint != null && var.backup_endpoint != "")
    error_message = "Backup endpoint cannot be an empty string if provided."
  }
}

variable "enable_health_checks" {
  description = "Enable Route 53 health checks"
  type        = bool
  default     = true
}

variable "health_check_type" {
  description = "Type of health check (HTTP, HTTPS, TCP, HTTP_STR_MATCH, HTTPS_STR_MATCH, CALCULATED, CLOUDWATCH_METRIC)"
  type        = string
  default     = "HTTP"

  validation {
    condition = contains([
      "HTTP", "HTTPS", "TCP", "HTTP_STR_MATCH", 
      "HTTPS_STR_MATCH", "CALCULATED", "CLOUDWATCH_METRIC"
    ], var.health_check_type)
    error_message = "Health check type must be one of: HTTP, HTTPS, TCP, HTTP_STR_MATCH, HTTPS_STR_MATCH, CALCULATED, CLOUDWATCH_METRIC."
  }
}

variable "health_check_port" {
  description = "Port for health check"
  type        = number
  default     = 80

  validation {
    condition     = var.health_check_port >= 1 && var.health_check_port <= 65535
    error_message = "Health check port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "Path for HTTP/HTTPS health checks"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/.*$", var.health_check_path))
    error_message = "Health check path must start with a forward slash."
  }
}

variable "health_check_timeout" {
  description = "Timeout for health check in seconds"
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_timeout >= 1 && var.health_check_timeout <= 10
    error_message = "Health check timeout must be between 1 and 10 seconds."
  }
}

variable "health_check_search_string" {
  description = "String to search for in the response body for HTTP/HTTPS health checks"
  type        = string
  default     = null
}

variable "invert_healthcheck" {
  description = "Invert the health check status"
  type        = bool
  default     = false
}

variable "measure_latency" {
  description = "Measure latency for health checks"
  type        = bool
  default     = false
}

variable "health_check_regions" {
  description = "List of regions to perform health checks from. Must be valid AWS regions."
  type        = list(string)
  default     = ["us-east-1"]

  validation {
    condition = alltrue([
      for region in var.health_check_regions : 
      contains([
        "us-east-1", "us-west-1", "us-west-2", "eu-west-1", 
        "eu-central-1", "ap-southeast-1", "ap-southeast-2", 
        "ap-northeast-1", "sa-east-1"
      ], region)
    ])
    error_message = "Health check regions must be valid AWS regions."
  }

  validation {
    condition     = length(var.health_check_regions) > 0
    error_message = "At least one region must be specified for health checks."
  }
}

variable "child_healthchecks" {
  description = "List of child health check IDs for calculated health checks"
  type        = list(string)
  default     = []
}

variable "child_health_threshold" {
  description = "Number of child health checks that must be healthy for calculated health check to be healthy"
  type        = number
  default     = 1

  validation {
    condition     = var.child_health_threshold >= 1 && var.child_health_threshold <= 256
    error_message = "Child health threshold must be between 1 and 256."
  }
}

variable "enable_sni" {
  description = "Enable Server Name Indication for HTTPS health checks"
  type        = bool
  default     = false
}

variable "insufficient_data_health_status" {
  description = "Health status when there is insufficient data (Healthy, Unhealthy, LastKnownStatus)"
  type        = string
  default     = null

  validation {
    condition = var.insufficient_data_health_status == null || contains([
      "Healthy", "Unhealthy", "LastKnownStatus"
    ], var.insufficient_data_health_status)
    error_message = "Insufficient data health status must be one of: Healthy, Unhealthy, LastKnownStatus."
  }
}

variable "failure_threshold" {
  description = "Number of consecutive health check failures required before marking endpoint as unhealthy"
  type        = number
  default     = 3

  validation {
    condition     = var.failure_threshold >= 1 && var.failure_threshold <= 10
    error_message = "Failure threshold must be between 1 and 10."
  }
}

variable "request_interval" {
  description = "Time interval between health check requests in seconds"
  type        = number
  default     = 30

  validation {
    condition     = contains([10, 30], var.request_interval)
    error_message = "Request interval must be either 10 or 30 seconds."
  }
}

variable "create_hosted_zone" {
  description = "Create a new Route 53 hosted zone"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for the hosted zone (required if create_hosted_zone is true). Must be a valid domain name."
  type        = string
  default     = null

  validation {
    condition     = var.create_hosted_zone == false || (var.domain_name != null && var.domain_name != "")
    error_message = "Domain name is required when creating a hosted zone."
  }

  validation {
    condition     = var.domain_name == null || can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", var.domain_name))
    error_message = "Domain name must be a valid domain format."
  }
}

variable "hosted_zone_comment" {
  description = "Comment for the hosted zone"
  type        = string
  default     = "Managed by Terraform"
}

variable "hosted_zone_force_destroy" {
  description = "Force destroy the hosted zone even if it contains records"
  type        = bool
  default     = false
}

variable "hosted_zone_delegation_set_id" {
  description = "Delegation set ID for the hosted zone"
  type        = string
  default     = null
}

variable "hosted_zone_id" {
  description = "Existing Route 53 hosted zone ID (required if create_hosted_zone is false)"
  type        = string
  default     = null

  validation {
    condition     = var.create_hosted_zone == true || (var.hosted_zone_id != null && var.hosted_zone_id != "")
    error_message = "Hosted zone ID is required when not creating a hosted zone."
  }
}

variable "record_name" {
  description = "DNS record name"
  type        = string
  default     = "api"

  validation {
    condition     = var.record_name != null && var.record_name != ""
    error_message = "Record name is required."
  }
}

variable "record_type" {
  description = "DNS record type"
  type        = string
  default     = "A"

  validation {
    condition     = contains(["A", "AAAA", "CNAME", "TXT", "MX", "NS"], var.record_type)
    error_message = "Record type must be one of: A, AAAA, CNAME, TXT, MX, NS."
  }
}

variable "alias_zone_id" {
  description = "Zone ID for alias records (e.g., ALB, CloudFront distribution)"
  type        = string
  default     = null
}

variable "evaluate_target_health" {
  description = "Evaluate target health for alias records"
  type        = bool
  default     = true
}

variable "ttl" {
  description = "Time to live for DNS records in seconds"
  type        = number
  default     = 300

  validation {
    condition     = var.ttl >= 0 && var.ttl <= 2147483647
    error_message = "TTL must be between 0 and 2147483647 seconds."
  }
}

variable "latency_routing_region" {
  description = "Region for latency-based routing"
  type        = string
  default     = null
}

variable "geolocation_continent" {
  description = "Continent for geolocation-based routing"
  type        = string
  default     = null
}

variable "geolocation_country" {
  description = "Country for geolocation-based routing"
  type        = string
  default     = null
}

variable "geolocation_subdivision" {
  description = "Subdivision for geolocation-based routing"
  type        = string
  default     = null
}

variable "weighted_routing_weight" {
  description = "Weight for weighted routing"
  type        = number
  default     = 1

  validation {
    condition     = var.weighted_routing_weight >= 0 && var.weighted_routing_weight <= 255
    error_message = "Weighted routing weight must be between 0 and 255."
  }
}

variable "multivalue_answer_routing_policy" {
  description = "Enable multivalue answer routing policy"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for health check failures"
  type        = bool
  default     = true
}

variable "alarm_comparison_operator" {
  description = "Comparison operator for CloudWatch alarms"
  type        = string
  default     = "LessThanThreshold"

  validation {
    condition = contains([
      "GreaterThanOrEqualToThreshold", "GreaterThanThreshold", 
      "LessThanThreshold", "LessThanOrEqualToThreshold"
    ], var.alarm_comparison_operator)
    error_message = "Alarm comparison operator must be a valid CloudWatch comparison operator."
  }
}

variable "alarm_evaluation_periods" {
  description = "Number of evaluation periods for CloudWatch alarms"
  type        = number
  default     = 2

  validation {
    condition     = var.alarm_evaluation_periods >= 1 && var.alarm_evaluation_periods <= 10
    error_message = "Alarm evaluation periods must be between 1 and 10."
  }
}

variable "alarm_metric_name" {
  description = "Metric name for CloudWatch alarms"
  type        = string
  default     = "HealthCheckStatus"
}

variable "alarm_namespace" {
  description = "Namespace for CloudWatch alarms"
  type        = string
  default     = "AWS/Route53"
}

variable "alarm_period" {
  description = "Period for CloudWatch alarms in seconds"
  type        = number
  default     = 60

  validation {
    condition     = var.alarm_period >= 10 && var.alarm_period <= 86400
    error_message = "Alarm period must be between 10 and 86400 seconds."
  }
}

variable "alarm_statistic" {
  description = "Statistic for CloudWatch alarms"
  type        = string
  default     = "Average"

  validation {
    condition = contains([
      "SampleCount", "Average", "Sum", "Minimum", "Maximum"
    ], var.alarm_statistic)
    error_message = "Alarm statistic must be a valid CloudWatch statistic."
  }
}

variable "alarm_threshold" {
  description = "Threshold for CloudWatch alarms"
  type        = number
  default     = 1.0
}

variable "alarm_description" {
  description = "Description for CloudWatch alarms"
  type        = string
  default     = "Health check failure alarm"
}

variable "alarm_actions" {
  description = "List of ARNs for CloudWatch alarm actions (SNS topics, etc.)"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs for CloudWatch OK actions (SNS topics, etc.)"
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "List of ARNs for CloudWatch insufficient data actions"
  type        = list(string)
  default     = []
}

variable "treat_missing_data" {
  description = "How to treat missing data in CloudWatch alarms"
  type        = string
  default     = "missing"

  validation {
    condition = contains([
      "missing", "notBreaching", "breaching", "ignore"
    ], var.treat_missing_data)
    error_message = "Treat missing data must be one of: missing, notBreaching, breaching, ignore."
  }
}

variable "datapoints_to_alarm" {
  description = "Number of datapoints that must be breaching to trigger alarm"
  type        = number
  default     = null

  validation {
    condition = var.datapoints_to_alarm == null || (var.datapoints_to_alarm >= 1 && var.datapoints_to_alarm <= var.alarm_evaluation_periods)
    error_message = "Datapoints to alarm must be between 1 and evaluation periods."
  }
}

variable "extended_statistic" {
  description = "Extended statistic for CloudWatch alarms"
  type        = string
  default     = null
}

variable "alarm_unit" {
  description = "Unit for CloudWatch alarms"
  type        = string
  default     = null
}

variable "enable_sns_notifications" {
  description = "Enable SNS notifications for health check events"
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Email address for SNS notifications"
  type        = string
  default     = null

  validation {
    condition     = var.notification_email == null || can(regex("^[^@]+@[^@]+\\.[^@]+$", var.notification_email))
    error_message = "Notification email must be a valid email address."
  }
}

variable "sns_topic_display_name" {
  description = "Display name for SNS topic"
  type        = string
  default     = null
}

variable "sns_topic_kms_key_id" {
  description = "KMS key ID for SNS topic encryption"
  type        = string
  default     = null
}

variable "sns_topic_fifo" {
  description = "Enable FIFO (First-In-First-Out) for SNS topic"
  type        = bool
  default     = false
}

variable "sns_topic_content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO SNS topic"
  type        = bool
  default     = false
}

variable "sns_subscription_confirmation_timeout" {
  description = "Confirmation timeout in minutes for SNS subscription"
  type        = number
  default     = 1

  validation {
    condition     = var.sns_subscription_confirmation_timeout >= 1 && var.sns_subscription_confirmation_timeout <= 20
    error_message = "SNS subscription confirmation timeout must be between 1 and 20 minutes."
  }
}

variable "sns_subscription_delivery_policy" {
  description = "Delivery policy for SNS subscription"
  type        = string
  default     = null
}

variable "sns_subscription_filter_policy" {
  description = "Filter policy for SNS subscription"
  type        = string
  default     = null
}

variable "sns_subscription_filter_policy_scope" {
  description = "Filter policy scope for SNS subscription"
  type        = string
  default     = null

  validation {
    condition = var.sns_subscription_filter_policy_scope == null || contains([
      "MessageAttributes", "MessageBody"
    ], var.sns_subscription_filter_policy_scope)
    error_message = "SNS subscription filter policy scope must be one of: MessageAttributes, MessageBody."
  }
}

variable "sns_subscription_raw_message_delivery" {
  description = "Enable raw message delivery for SNS subscription"
  type        = bool
  default     = false
}

variable "sns_subscription_redrive_policy" {
  description = "Redrive policy for SNS subscription"
  type        = string
  default     = null
}

variable "sns_subscription_role_arn" {
  description = "IAM role ARN for SNS subscription"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : can(regex("^[a-zA-Z0-9_.:/=+-@]+$", k))])
    error_message = "Tag keys must contain only alphanumeric characters, underscores, periods, colons, slashes, equals, plus signs, hyphens, and at signs."
  }
} 