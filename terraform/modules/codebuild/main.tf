# CodeBuild Project
resource "aws_codebuild_project" "app" {
  name          = "${var.project_name}-${var.environment}-build"
  description   = "Build project for ${var.project_name}"
  service_role  = var.codebuild_role_arn
  build_timeout = 30

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.docker_image_repo_name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = var.docker_image_tag
    }

    environment_variable {
      name  = "S3_BUCKET"
      value = var.s3_bucket_name
    }

    environment_variable {
      name  = "DOCKER_REGISTRY_USERNAME"
      value = "/myapp/docker-credentials/username"
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "DOCKER_REGISTRY_PASSWORD"
      value = "/myapp/docker-credentials/password"
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "DOCKER_REGISTRY_URL"
      value = "/myapp/docker-registry/url"
      type  = "PARAMETER_STORE"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project_name}-${var.environment}"
      stream_name = "build-log"
      status      = "ENABLED"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-build"
  }
}

# CloudWatch Log Group for CodeBuild
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${var.project_name}-${var.environment}"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-${var.environment}-codebuild-logs"
  }
}
