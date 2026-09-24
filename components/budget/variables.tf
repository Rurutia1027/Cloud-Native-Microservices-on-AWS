variable "budget_name" {
  description = "Name of the AWS monthly cost budget."
  type        = string

  validation {
    condition     = length(trimspace(var.budget_name)) > 0 && length(var.budget_name) <= 100
    error_message = "budget_name must be between 1 and 100 characters."
  }
}

variable "monthly_limit" {
  description = "Monthly AWS cost budget in USD."
  type        = number

  validation {
    condition     = var.monthly_limit > 0
    error_message = "monthly_limit must be greater than 0."
  }
}

variable "actual_warning_threshold" {
  description = "Actual cost warning threshold as a percentage of the monthly budget."
  type        = number
  default     = 80

  validation {
    condition     = var.actual_warning_threshold > 0 && var.actual_warning_threshold <= 100
    error_message = "actual_warning_threshold must be in (0, 100]."
  }
}

variable "actual_critical_threshold" {
  description = "Actual cost critical threshold as a percentage of the monthly budget."
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

variable "notification_emails" {
  description = "Email addresses that receive AWS Budget notifications. AWS allows up to 10 subscribers per notification."
  type        = list(string)

  validation {
    condition = (
      length(var.notification_emails) > 0 &&
      length(var.notification_emails) <= 10 &&
      length(distinct(var.notification_emails)) == length(var.notification_emails) &&
      alltrue([
        for email in var.notification_emails :
        can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", email))
      ])
    )
    error_message = "Provide 1–10 unique, valid notification email addresses."
  }
}

variable "tags" {
  description = "Tags applied to the AWS Budget."
  type        = map(string)
  default     = {}
}
