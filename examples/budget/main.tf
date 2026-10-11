locals {
  notifications = [
    {
      notification_type = "ACTUAL"
      threshold         = var.actual_warning_threshold
    },
    {
      notification_type = "ACTUAL"
      threshold         = var.actual_critical_threshold
    },
    {
      notification_type = "FORECASTED"
      threshold         = var.forecast_threshold
    },
  ]

  daily_budget_name = "${var.budget_name}-daily"

  # AWS rejects FORECASTED notifications when time_unit is DAILY.
  daily_notifications = [
    for notification in local.notifications : notification
    if notification.notification_type == "ACTUAL"
  ]

  tags = {
    Project     = "cloud-native-lab"
    Component   = "budget"
    Environment = "lab"
  }
}

resource "aws_budgets_budget" "monthly" {
  name         = var.budget_name
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_limit)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Track unblended spend. Exclude credits and refunds so alerts are not muted by billing adjustments.
  cost_types {
    include_credit             = false
    include_refund             = false
    include_tax                = true
    include_support            = true
    include_subscription       = true
    include_recurring          = true
    include_upfront            = true
    include_other_subscription = true
    include_discount           = true
    use_blended                = false
  }

  dynamic "notification" {
    for_each = local.notifications

    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value.threshold
      threshold_type             = "PERCENTAGE"
      notification_type          = notification.value.notification_type
      subscriber_email_addresses = [var.notification_email]
    }
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = var.actual_warning_threshold < var.actual_critical_threshold
      error_message = "actual_warning_threshold must be less than actual_critical_threshold."
    }
  }
}

resource "aws_budgets_budget" "daily" {
  name         = local.daily_budget_name
  budget_type  = "COST"
  limit_amount = tostring(var.daily_limit)
  limit_unit   = "USD"
  time_unit    = "DAILY"

  # Same cost basis as the monthly budget.
  cost_types {
    include_credit             = false
    include_refund             = false
    include_tax                = true
    include_support            = true
    include_subscription       = true
    include_recurring          = true
    include_upfront            = true
    include_other_subscription = true
    include_discount           = true
    use_blended                = false
  }

  dynamic "notification" {
    for_each = local.daily_notifications

    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value.threshold
      threshold_type             = "PERCENTAGE"
      notification_type          = notification.value.notification_type
      subscriber_email_addresses = [var.notification_email]
    }
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = length(local.daily_budget_name) <= 100
      error_message = "budget_name plus \"-daily\" must be at most 100 characters."
    }
  }
}

moved {
  from = module.budget.aws_budgets_budget.this
  to   = aws_budgets_budget.monthly
}

moved {
  from = module.budget.aws_budgets_budget.daily
  to   = aws_budgets_budget.daily
}
