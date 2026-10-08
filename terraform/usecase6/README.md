# Use Case 6: Build Low-Cost AWS Infrastructure with Terraform

This branch is a standalone, executable lab for describing a small AWS
infrastructure slice as code. It focuses on reviewing the plan before applying,
inspecting outputs and state, detecting drift, and cleaning up.

## Cost boundary

This lab intentionally creates no EC2 instance, NAT Gateway, Internet Gateway,
Elastic IP, public IPv4 address, load balancer, RDS database, EKS cluster,
Secrets Manager secret, Route 53 hosted zone, or customer-managed KMS key.

It creates:

- one VPC with two private subnets and a private route table;
- one security group with no inbound rules;
- one IAM role and inline least-privilege policy;
- one empty private S3 bucket encrypted with SSE-S3;
- one empty private ECR repository;
- one empty CloudWatch log group with seven-day retention; and
- one USD 5 monthly AWS Budget alert.

Keep the S3 bucket, ECR repository, and log group empty. The AWS Budget is an
alert and is not a hard spending limit. Always run `terraform destroy` when the
lab is complete and confirm the resources are gone.

## 1. Prerequisites

You need:

- an AWS lab account that is not a shared production account;
- an IAM user or IAM Identity Center session with permission to manage the lab
  resources;
- Homebrew on macOS;
- Terraform CLI; and
- AWS CLI v2.

Install the command-line tools on macOS:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew install awscli
```

Verify them:

```bash
terraform version
aws --version
```

Configure AWS credentials. Prefer short-lived IAM Identity Center credentials:

```bash
aws configure sso
aws sso login --profile YOUR_PROFILE
export AWS_PROFILE=YOUR_PROFILE
```

If your lab uses access keys instead:

```bash
aws configure
```

Never put AWS keys in Terraform files, `terraform.tfvars`, screenshots, or Git.

Confirm the account before creating anything:

```bash
aws sts get-caller-identity
```

Stop if the account is shared or production.

## 2. Clone this exact use-case branch

GitLab:

```bash
cd /Users/midhtech_01
git clone \
  --branch usecase/06-terraform-cloud-infrastructure \
  --single-branch \
  https://gitlab.com/midhtech-group2/3-tier-architecture.git \
  3-Tier-Architecture-UseCase6
cd 3-Tier-Architecture-UseCase6
```

GitHub alternative:

```bash
cd /Users/midhtech_01
git clone \
  --branch usecase/06-terraform-cloud-infrastructure \
  --single-branch \
  https://github.com/Abhignaambati/3-Tier-Architecture.git \
  3-Tier-Architecture-UseCase6
cd 3-Tier-Architecture-UseCase6
```

## 3. Prepare local variables

```bash
cd terraform/usecase6
cp terraform.tfvars.example terraform.tfvars
open -a "Visual Studio Code" terraform.tfvars
```

Replace `budget_email` with your real email. If you exported `AWS_PROFILE`, keep
`aws_profile = null`. Otherwise, set it to your configured profile name. The
real `terraform.tfvars` file is ignored by Git.

Create the local evidence directory:

```bash
mkdir -p usecase6-evidence
```

## 4. Format, initialize, and validate

```bash
terraform fmt -recursive
terraform init 2>&1 | tee usecase6-evidence/terraform-init.txt
terraform validate 2>&1 | tee usecase6-evidence/terraform-validate.txt
```

Expected validation result:

```text
Success! The configuration is valid.
```

## 5. Controlled failure and recovery

Use an invalid CIDR to prove variable validation stops a bad configuration:

```bash
terraform plan \
  -var-file=terraform.tfvars \
  -var='vpc_cidr=not-a-cidr' \
  2>&1 | tee usecase6-evidence/controlled-failure.txt
```

Expected result: Terraform rejects `vpc_cidr` before creating resources.

Recover by using the valid value already present in `terraform.tfvars`:

```bash
terraform validate 2>&1 | tee usecase6-evidence/recovery-validation.txt
```

## 6. Create and review the plan

```bash
terraform plan \
  -var-file=terraform.tfvars \
  -out=tfplan \
  2>&1 | tee usecase6-evidence/terraform-plan.txt
```

Read the plan before applying:

```bash
terraform show tfplan | less
```

Confirm the plan contains only the resources listed in the cost boundary.
Stop if it shows EC2, NAT Gateway, Elastic IP, public IPv4, load balancer, RDS,
EKS, Secrets Manager, Route 53, or KMS resources. Confirm there are zero
resources to change or destroy on the first plan.

## 7. Apply the reviewed plan

Only apply the saved plan you reviewed:

```bash
terraform apply tfplan \
  2>&1 | tee usecase6-evidence/terraform-apply.txt
```

Do not run a fresh `terraform apply` without the saved plan.

## 8. Inspect outputs, state, and AWS

```bash
terraform output \
  | tee usecase6-evidence/terraform-outputs.txt

terraform state list \
  | tee usecase6-evidence/terraform-state-list.txt

aws ec2 describe-vpcs \
  --vpc-ids "$(terraform output -raw vpc_id)" \
  | tee usecase6-evidence/aws-vpc.txt

aws s3api get-bucket-encryption \
  --bucket "$(terraform output -raw artifact_bucket_name)" \
  | tee usecase6-evidence/aws-s3-encryption.txt

aws ecr describe-repositories \
  --repository-names "$(terraform output -raw ecr_repository_url | awk -F/ '{print $2}')" \
  | tee usecase6-evidence/aws-ecr.txt
```

## 9. Demonstrate drift detection and correction

Add a safe manual tag to the Terraform-managed S3 bucket:

```bash
aws s3api put-bucket-tagging \
  --bucket "$(terraform output -raw artifact_bucket_name)" \
  --tagging 'TagSet=[{Key=ManualDrift,Value=true}]'
```

Terraform should detect the live change:

```bash
terraform plan \
  -var-file=terraform.tfvars \
  -out=drift.tfplan \
  2>&1 | tee usecase6-evidence/drift-plan.txt
```

Correct the drift:

```bash
terraform apply drift.tfplan \
  2>&1 | tee usecase6-evidence/drift-correction.txt
```

Verify there is no remaining drift:

```bash
terraform plan \
  -var-file=terraform.tfvars \
  -detailed-exitcode \
  2>&1 | tee usecase6-evidence/final-no-change-plan.txt
```

Exit code `0` means no changes remain.

## 10. Destroy and prove cleanup

The repositories and bucket must remain empty for clean destruction.

```bash
terraform plan \
  -destroy \
  -var-file=terraform.tfvars \
  -out=destroy.tfplan \
  2>&1 | tee usecase6-evidence/terraform-destroy-plan.txt

terraform apply destroy.tfplan \
  2>&1 | tee usecase6-evidence/terraform-destroy.txt

terraform state list \
  | tee usecase6-evidence/state-after-destroy.txt
```

The final state list should be empty. Also check the AWS Billing and Cost
Management console and confirm no unexpected resources or costs remain.

## Evidence checklist

Save these locally. They are ignored by Git because they may contain AWS account
IDs and resource identifiers:

- `terraform-init.txt`
- `terraform-validate.txt`
- `controlled-failure.txt`
- `recovery-validation.txt`
- `terraform-plan.txt`
- `terraform-apply.txt`
- `terraform-outputs.txt`
- `terraform-state-list.txt`
- `drift-plan.txt`
- `drift-correction.txt`
- `final-no-change-plan.txt`
- `terraform-destroy-plan.txt`
- `terraform-destroy.txt`
- `state-after-destroy.txt`

Never commit `terraform.tfvars`, Terraform state, saved plans, AWS credentials,
account IDs, or evidence containing sensitive identifiers.
