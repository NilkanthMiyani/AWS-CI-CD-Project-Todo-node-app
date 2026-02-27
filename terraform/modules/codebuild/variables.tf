variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN of the CodeBuild IAM role"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 artifacts bucket"
  type        = string
}

variable "docker_image_repo_name" {
  description = "Docker image repository name"
  type        = string
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
}
