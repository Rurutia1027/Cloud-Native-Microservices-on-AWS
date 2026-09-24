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
  description = "AWS Budget name."
  type        = string
  default     = "cloudnative-lab"
}

variable "monthly_limit" {
  description = "Monthly AWS cost budget in USD."
  type        = number
  default     = 50
}

variable "notification_email" {
  description = "Email address for AWS Budget notifications."
  type        = string
}
