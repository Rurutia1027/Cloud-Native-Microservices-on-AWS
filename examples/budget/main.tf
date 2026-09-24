module "budget" {
  source = "../../components/budget"

  budget_name         = var.budget_name
  monthly_limit       = var.monthly_limit
  notification_emails = [var.notification_email]

  tags = {
    Project     = "cloud-native-lab"
    Component   = "budget"
    Environment = "lab"
  }
}
