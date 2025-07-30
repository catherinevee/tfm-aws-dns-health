# Route 53 Health Checks + Failover Module Variables

variable "name_prefix" {
  description = "Prefix for resource names"
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
  description = "Primary endpoint FQDN or IP address"
  type        = string

  validation {
    condition     = var.primary_endpoint != null && var.primary_endpoint != ""
    error_message = "Primary endpoint is required."
  }
}

variable "backup_endpoint" {
  description = "Backup endpoint FQDN or IP address (optional)"
  type        = string
  default     = null
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
  description = "Domain name for the hosted zone (required if create_hosted_zone is true)"
  type        = string
  default     = null

  validation {
    condition     = var.create_hosted_zone == false || (var.domain_name != null && var.domain_name != "")
    error_message = "Domain name is required when creating a hosted zone."
  }
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

variable "ttl" {
  description = "Time to live for DNS records in seconds"
  type        = number
  default     = 300

  validation {
    condition     = var.ttl >= 0 && var.ttl <= 2147483647
    error_message = "TTL must be between 0 and 2147483647 seconds."
  }
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for health check failures"
  type        = bool
  default     = true
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

variable "alarm_period" {
  description = "Period for CloudWatch alarms in seconds"
  type        = number
  default     = 60

  validation {
    condition     = var.alarm_period >= 10 && var.alarm_period <= 86400
    error_message = "Alarm period must be between 10 and 86400 seconds."
  }
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : can(regex("^[a-zA-Z0-9_.:/=+-@]+$", k))])
    error_message = "Tag keys must contain only alphanumeric characters, underscores, periods, colons, slashes, equals, plus signs, hyphens, and at signs."
  }
} 