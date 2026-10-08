variable "aws_region" {
  description = "AWS region for the lab resources."
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile. Leave null to use the default credential chain."
  type        = string
  default     = null
  nullable    = true
}

variable "project_name" {
  description = "Short lowercase project name used in resource names."
  type        = string
  default     = "claims-usecase6"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,23}$", var.project_name))
    error_message = "project_name must be 3-24 lowercase letters, digits, or hyphens and start with a letter."
  }
}

variable "environment" {
  description = "Lab environment name."
  type        = string
  default     = "lab"

  validation {
    condition     = contains(["lab", "dev", "test"], var.environment)
    error_message = "environment must be lab, dev, or test. Production is intentionally blocked."
  }
}

variable "vpc_cidr" {
  description = "Private CIDR block for the lab VPC."
  type        = string
  default     = "10.60.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block, for example 10.60.0.0/16."
  }
}

variable "budget_email" {
  description = "Email address that receives AWS Budget alerts."
  type        = string

  validation {
    condition     = can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", var.budget_email))
    error_message = "budget_email must be a valid email address."
  }
}

variable "monthly_budget_usd" {
  description = "Monthly warning budget in USD. This is an alert, not a hard spending cap."
  type        = number
  default     = 5

  validation {
    condition     = var.monthly_budget_usd >= 1 && var.monthly_budget_usd <= 10
    error_message = "monthly_budget_usd must be between 1 and 10 for this lab."
  }
}
