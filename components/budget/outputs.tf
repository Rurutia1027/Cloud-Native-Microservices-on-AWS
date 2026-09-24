output "budget_name" {
  description = "Name of the AWS Budget."
  value       = aws_budgets_budget.this.name
}

output "budget_arn" {
  description = "ARN of the AWS Budget."
  value       = aws_budgets_budget.this.arn
}

output "monthly_limit" {
  description = "Monthly budget limit in USD."
  value       = aws_budgets_budget.this.limit_amount
}

output "actual_warning_amount" {
  description = "USD amount that triggers the actual-cost warning notification."
  value       = var.monthly_limit * var.actual_warning_threshold / 100
}

output "actual_critical_amount" {
  description = "USD amount that triggers the actual-cost critical notification."
  value       = var.monthly_limit * var.actual_critical_threshold / 100
}
