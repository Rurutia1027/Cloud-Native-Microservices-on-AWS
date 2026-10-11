variable "aws_region" {
  description = "AWS region for the provider. AWS Budgets is a global service; this is only used for authentication."
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile used by the provider."
  type        = string
  default     = "cloudnative-lab"
}

variable "budget_name" {
  description = "Name of the AWS monthly cost budget. The daily budget is named <budget_name>-daily."
  type        = string
  default     = "cloudnative-lab"

  validation {
    condition     = length(trimspace(var.budget_name)) > 0 && length(var.budget_name) <= 100
    error_message = "budget_name must be between 1 and 100 characters."
  }
}

variable "monthly_limit" {
  description = "Monthly AWS cost budget in USD."
  type        = number
  default     = 50

  validation {
    condition     = var.monthly_limit > 0
    error_message = "monthly_limit must be greater than 0."
  }
}

variable "daily_limit" {
  description = "Daily AWS cost budget in USD."
  type        = number
  default     = 5

  validation {
    condition     = var.daily_limit > 0
    error_message = "daily_limit must be greater than 0."
  }
}

variable "actual_warning_threshold" {
  description = "Actual cost warning threshold as a percentage of each budget."
  type        = number
  default     = 80

  validation {
    condition     = var.actual_warning_threshold > 0 && var.actual_warning_threshold <= 100
    error_message = "actual_warning_threshold must be in (0, 100]."
  }
}

variable "actual_critical_threshold" {
  description = "Actual cost critical threshold as a percentage of each budget."
  type        = number
  default     = 100

  validation {
    condition     = var.actual_critical_threshold > 0 && var.actual_critical_threshold <= 100
    error_message = "actual_critical_threshold must be in (0, 100]."
  }
}

variable "forecast_threshold" {
  description = "Forecasted cost alert threshold as a percentage of the monthly budget."
  type        = number
  default     = 100

  validation {
    condition     = var.forecast_threshold > 0 && var.forecast_threshold <= 100
    error_message = "forecast_threshold must be in (0, 100]."
  }
}

variable "notification_email" {
  description = "Email address for AWS Budget notifications."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.notification_email))
    error_message = "notification_email must be a valid email address."
  }
}
