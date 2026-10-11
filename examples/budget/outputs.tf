output "budget_name" {
  description = "Name of the AWS Budget."
  value       = aws_budgets_budget.monthly.name
}

output "budget_arn" {
  description = "ARN of the AWS Budget."
  value       = aws_budgets_budget.monthly.arn
}

output "monthly_limit" {
  description = "Monthly budget limit in USD."
  value       = aws_budgets_budget.monthly.limit_amount
}

output "actual_warning_amount" {
  description = "USD amount that triggers the actual-cost warning."
  value       = var.monthly_limit * var.actual_warning_threshold / 100
}

output "actual_critical_amount" {
  description = "USD amount that triggers the actual-cost critical alert."
  value       = var.monthly_limit * var.actual_critical_threshold / 100
}

output "daily_budget_name" {
  description = "Name of the daily AWS Budget."
  value       = aws_budgets_budget.daily.name
}

output "daily_budget_arn" {
  description = "ARN of the daily AWS Budget."
  value       = aws_budgets_budget.daily.arn
}

output "daily_limit" {
  description = "Daily budget limit in USD."
  value       = aws_budgets_budget.daily.limit_amount
}

output "daily_actual_warning_amount" {
  description = "USD amount that triggers the daily actual-cost warning."
  value       = var.daily_limit * var.actual_warning_threshold / 100
}

output "daily_actual_critical_amount" {
  description = "USD amount that triggers the daily actual-cost critical alert."
  value       = var.daily_limit * var.actual_critical_threshold / 100
}
