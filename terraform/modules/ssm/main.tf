# SSM Parameter for Docker Hub Username
resource "aws_ssm_parameter" "docker_username" {
  name        = "/myapp/docker-credentials/username"
  description = "Docker Hub username for CI/CD pipeline"
  type        = "String"
  value       = var.docker_hub_username

  tags = {
    Name = "${var.project_name}-${var.environment}-docker-username"
  }
}

# SSM Parameter for Docker Hub Password (SecureString)
resource "aws_ssm_parameter" "docker_password" {
  name        = "/myapp/docker-credentials/password"
  description = "Docker Hub password for CI/CD pipeline"
  type        = "SecureString"
  value       = var.docker_hub_password

  tags = {
    Name = "${var.project_name}-${var.environment}-docker-password"
  }
}

# SSM Parameter for Docker Registry URL
resource "aws_ssm_parameter" "docker_registry_url" {
  name        = "/myapp/docker-registry/url"
  description = "Docker registry URL for CI/CD pipeline"
  type        = "String"
  value       = var.docker_registry_url

  tags = {
    Name = "${var.project_name}-${var.environment}-docker-registry-url"
  }
}
