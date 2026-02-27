# CodeStar Connection to GitHub
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project_name}-${var.environment}-github-connection"
  provider_type = "GitHub"

  tags = {
    Name = "${var.project_name}-${var.environment}-github-connection"
  }
}
