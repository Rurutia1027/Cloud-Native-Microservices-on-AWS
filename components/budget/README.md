# AWS Budget Component

Reusable Terraform component for a monthly AWS cost budget with actual and forecasted email notifications.

## Purpose

This is a cost-governance layer for the Cloud Native Lab. Apply it before VPC, EKS, or RDS so spend is visible from day one.

The component creates:

- A monthly COST budget
- Actual-cost warning and critical notifications
- A forecasted-cost notification
- Email subscribers on every notification

## Default Policy

The lab default is a **$50** monthly budget:

| Signal | Threshold | At $50 |
|---|---|---|
| Actual warning | 80% | $40 |
| Actual critical | 100% | $50 |
| Forecasted alert | 100% | $50 forecast |

AWS Budgets updates a few times per day, often 8–12 hours after usage. Treat this as governance, not a hard spend cap.

## Daily Cost Target

The lab also uses about **$10/day** as an operational watchpoint. That daily figure is not enforced here. A later component can add daily monitoring with cost data and event-driven automation.

## Usage

```hcl
module "budget" {
  source = "../../components/budget"

  budget_name   = "cloudnative-lab"
  monthly_limit = 50

  notification_emails = [
    "your-email@example.com"
  ]
}
```

Recipients must confirm the AWS subscription email before alerts are delivered.

## Variables

| Name | Type | Default | Description |
|---|---|---|---|
| `budget_name` | string | required | AWS Budget name (1–100 characters) |
| `monthly_limit` | number | required | Monthly budget in USD |
| `actual_warning_threshold` | number | `80` | Actual-cost warning percentage |
| `actual_critical_threshold` | number | `100` | Actual-cost critical percentage. Must be greater than the warning threshold |
| `forecast_threshold` | number | `100` | Forecasted-cost alert percentage |
| `notification_emails` | list(string) | required | 1–10 unique recipient addresses |
| `tags` | map(string) | `{}` | Tags on the budget |

## Outputs

| Name | Description |
|---|---|
| `budget_name` | Budget name |
| `budget_arn` | Budget ARN |
| `monthly_limit` | Limit in USD |
| `actual_warning_amount` | Warning amount in USD |
| `actual_critical_amount` | Critical amount in USD |

## Prerequisites

### Terraform on Apple Silicon

`plan` / `apply` hanging on `timeout while waiting for plugin to start` is usually the **Intel** Terraform binary running under Rosetta, not a wrong AWS region.

Use a native **darwin_arm64** Terraform (for example `~/.local/bin/terraform`) and put that directory **first** on `PATH` so it wins over `/usr/local/bin/terraform`:

```shell
# ~/.zshrc — keep this after other PATH exports
export PATH="$HOME/.local/bin:$PATH"
```

Then:

```shell
source ~/.zshrc
hash -r
terraform version    # must print: on darwin_arm64
which terraform      # ~/.local/bin/terraform
```

After switching architecture, re-init the example so the AWS provider is `darwin_arm64` as well:

```shell
cd examples/budget
rm -rf .terraform
terraform init
```

The example takes a single string `notification_email` (see `terraform.tfvars.example`). Pass it via `terraform.tfvars` (gitignored) and use `-input=false` so plan/apply do not prompt. A list value cannot be typed as a bare email at the prompt.

### IAM

The apply principal needs Budgets API access. A copy of the least-privilege policy is in [`iam-policy.json`](iam-policy.json):

- `budgets:ViewBudget`
- `budgets:ModifyBudget`
- `budgets:ListTagsForResource`
- `budgets:TagResource`
- `budgets:UntagResource`

The Cloud Native Lab user `terraform-cloudnative-lab` is in group `terraform-admin` with **`AdministratorAccess`**. That already includes the actions above. Console sign-in can stay disabled; Terraform uses the access key only.

That same user **cannot** attach policies to itself (`iam:PutUserPolicy` is denied even when you intend to add Budgets). Use the account **root** or a true admin to change IAM:

- Attach `AdministratorAccess` (or `iam-policy.json`) via a group, or
- Create an inline policy in the IAM console

`~/.aws` profiles such as `default` and `cloudnative-lab` may both map to this lab user. `--profile default` is not an admin profile unless that key belongs to a different IAM identity. Check with:

```shell
aws sts get-caller-identity --profile default
aws sts get-caller-identity --profile cloudnative-lab
```

AccessDenied on `budgets:ModifyBudget` with a valid key means the **identity policy** (or an org SCP) is missing, not that the access key is invalid.

## Deployment

From `examples/budget`:

```shell
cp terraform.tfvars.example terraform.tfvars
# set notification_email

terraform init
terraform validate
terraform plan -input=false
terraform apply -input=false
```

Review the plan before applying. `terraform.tfvars` is gitignored.

## Where to view the budget

AWS Budgets is a **global** Billing resource. It does not live in the `eu-west-1` EC2 console.

Open [AWS Budgets](https://console.aws.amazon.com/billing/home#/budgets) as root or any user with console access. The lab budget name is `cloudnative-lab`.

```shell
aws budgets describe-budget \
  --account-id <ACCOUNT_ID> \
  --budget-name cloudnative-lab \
  --profile cloudnative-lab
```

## Destroy

```shell
terraform destroy -input=false
```

Destroying the budget does not change other AWS infrastructure. A disabled access key will block destroy until you enable or replace the key on the apply profile.

## Design Notes

The component does not define provider credentials, account IDs, regions, or application infrastructure. That keeps it reusable. AWS Budgets is a global service; the provider region is only used for API authentication.

Cost types exclude credits and refunds so alerts reflect unblended spend, including tax and support.

## Future Extensions

- Daily cost monitoring
- Service- or environment-scoped budgets
- AWS Cost Anomaly Detection
- EventBridge cost events
- Slack / Teams notifications
- Cost dashboards
