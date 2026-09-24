output "budget_name" {
  description = "Name of the AWS Budget."
  value       = module.budget.budget_name
}

output "budget_arn" {
  description = "ARN of the AWS Budget."
  value       = module.budget.budget_arn
}

output "monthly_limit" {
  description = "Monthly budget limit in USD."
  value       = module.budget.monthly_limit
}

output "actual_warning_amount" {
  description = "USD amount that triggers the actual-cost warning."
  value       = module.budget.actual_warning_amount
}

output "actual_critical_amount" {
  description = "USD amount that triggers the actual-cost critical alert."
  value       = module.budget.actual_critical_amount
}
