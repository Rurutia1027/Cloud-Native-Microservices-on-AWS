# AWS Budget

This directory is the lab budget: the explanation and the Terraform that creates it. Apply it before VPC, EKS, or RDS so spend is visible from the first resource.

[`main.tf`](main.tf) creates:

- A monthly COST budget
- A daily COST budget
- Actual-cost warning and critical notifications on each budget
- A forecasted-cost notification on the monthly budget. Daily budgets accept actual notifications only
- One email subscriber on every notification

AWS Budgets sends email when a threshold is crossed. Resources keep running. Billing data updates a few times a day, often 8–12 hours after usage, so treat the email as a signal to open Cost Explorer. A daily alert can arrive after that UTC day has already passed. These budgets are governance, not a hard spend cap.

Recipients must confirm the AWS subscription email before alerts are delivered.

## Why these limits

The lab limits are **$50 per month** and **$5 per day** for the whole account. Both budgets cover every service, so NAT Gateway, EKS, and RDS share the same numbers.

| Alert | Monthly | Daily | Why |
|---|---|---|---|
| Actual 80% | $40 | $4 | Warning while there is still room to stop a workload |
| Actual 100% | $50 | $5 | Spend has passed the limit |
| Forecast 100% | $50 forecast | none | AWS projects the month will pass $50 before the actual charge gets there. A daily budget rejects forecast notifications |

`GREATER_THAN` fires only after the amount is passed. Spend that sits exactly on $40 or $50 waits for the next billing update.

The measured amount is unblended cost after discounts. Credits and refunds stay out, so a billing adjustment cannot hide real usage. Tax, support, and subscriptions stay in, so the $50 tracks charges that show up on the bill.

## Rules

| Rule | Value |
|---|---|
| Monthly budget | `COST`, `MONTHLY`, `USD`, limit `50`, name `cloudnative-lab` |
| Daily budget | `COST`, `DAILY`, `USD`, limit `5`, name `cloudnative-lab-daily` |
| Actual warning | `80` percent, must be lower than the critical threshold |
| Actual critical | `100` percent |
| Forecast | `100` percent, monthly budget only |
| Comparison | `GREATER_THAN` |
| Threshold type | `PERCENTAGE` |
| Recipient | one email, the same address on every alert |
| Budget name | 1–100 characters, unique in the account. The daily name is `<budget_name>-daily` |

## Where each decision lives

All of this is in [`main.tf`](main.tf) and [`variables.tf`](variables.tf).

- `local.notifications` is the only list of alert signals. The monthly budget uses all three. The daily budget keeps the `ACTUAL` entries, because AWS returns an error if a daily budget includes `FORECASTED`.
- `limit_amount` is a string because the AWS API requires one. The variables stay numbers, and `tostring` converts them.
- `cost_types` excludes credits and refunds, includes tax, support, and subscriptions, and sets `use_blended = false` so discounts lower the tracked amount.
- A `precondition` rejects a plan where the warning threshold is not below the critical threshold.
- Tags are the `local.tags` map on both budgets.
- `notification_email` has no default. Set it in `terraform.tfvars`.

## Variables

| Name | Type | Default | Description |
|---|---|---|---|
| `budget_name` | string | `cloudnative-lab` | AWS Budget name (1–100 characters) |
| `monthly_limit` | number | `50` | Monthly budget in USD |
| `daily_limit` | number | `5` | Daily budget in USD. Budget name is `<budget_name>-daily` |
| `actual_warning_threshold` | number | `80` | Actual-cost warning percentage |
| `actual_critical_threshold` | number | `100` | Actual-cost critical percentage. Must be greater than the warning threshold |
| `forecast_threshold` | number | `100` | Forecasted-cost alert percentage on the monthly budget |
| `notification_email` | string | required | Recipient address |
| `aws_region` | string | `eu-west-1` | Provider region. Budgets is global; this is only used for authentication |
| `aws_profile` | string | `cloudnative-lab` | Named AWS CLI profile |

## Outputs

| Name | Description |
|---|---|
| `budget_name` | Budget name |
| `budget_arn` | Budget ARN |
| `monthly_limit` | Limit in USD |
| `actual_warning_amount` | Warning amount in USD |
| `actual_critical_amount` | Critical amount in USD |
| `daily_budget_name` | Daily budget name |
| `daily_budget_arn` | Daily budget ARN |
| `daily_limit` | Daily limit in USD |
| `daily_actual_warning_amount` | Daily warning amount in USD |
| `daily_actual_critical_amount` | Daily critical amount in USD |

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

After switching architecture, re-init so the AWS provider is `darwin_arm64` as well:

```shell
rm -rf .terraform
terraform init
```

Pass `notification_email` via `terraform.tfvars` (gitignored) and use `-input=false` so plan/apply do not prompt.

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

Open [AWS Budgets](https://console.aws.amazon.com/billing/home#/budgets) as root or any user with console access. The lab budget names are `cloudnative-lab` and `cloudnative-lab-daily`.

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
