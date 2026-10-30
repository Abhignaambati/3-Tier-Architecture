terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

variable "aws_region" {
  description = "AWS region used for the lab"
  type        = string
  default     = "ap-south-1"
}

variable "role_name" {
  description = "Name of the free IAM drift lab role"
  type        = string
  default     = "claims-usecase16-drift-lab-role"
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "drift_lab" {
  name        = var.role_name
  description = "No-permission IAM role used only for the Use Case 16 drift lab"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEC2TrustForLab"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = var.role_name
    Project     = "claims-application"
    Environment = "lab"
    UseCase     = "16"
    ManagedBy   = "Terraform"
    DriftStatus = "ManagedByTerraform"
  }
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  value = var.aws_region
}

output "iam_role_name" {
  value = aws_iam_role.drift_lab.name
}

output "iam_role_arn" {
  value = aws_iam_role.drift_lab.arn
}
