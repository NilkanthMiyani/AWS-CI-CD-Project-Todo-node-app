variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy IAM role"
  type        = string
}
