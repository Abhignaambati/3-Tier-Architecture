output "aws_account_id" {
  description = "AWS account used by Terraform."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region used by Terraform."
  value       = var.aws_region
}

output "vpc_id" {
  description = "Lab VPC ID."
  value       = aws_vpc.lab.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "security_group_id" {
  description = "Application security group ID."
  value       = aws_security_group.app.id
}

output "artifact_bucket_name" {
  description = "Empty encrypted S3 artifact bucket."
  value       = aws_s3_bucket.artifacts.id
}

output "ecr_repository_url" {
  description = "Empty ECR repository URL."
  value       = aws_ecr_repository.app.repository_url
}

output "iam_role_arn" {
  description = "Lab IAM role ARN."
  value       = aws_iam_role.app.arn
}

output "cloudwatch_log_group" {
  description = "Empty CloudWatch log group."
  value       = aws_cloudwatch_log_group.app.name
}

output "budget_name" {
  description = "Monthly AWS Budget alert name."
  value       = aws_budgets_budget.lab.name
}
