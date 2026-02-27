# EC2 Instance Outputs
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.instance_public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2.instance_public_dns
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.ec2.instance_public_ip}:8000"
}

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

# S3 Outputs
output "s3_artifacts_bucket" {
  description = "Name of the S3 artifacts bucket"
  value       = module.s3.bucket_name
}

# CodeStar Connection Outputs
output "codestar_connection_arn" {
  description = "ARN of the CodeStar connection"
  value       = module.codestar.connection_arn
}

output "codestar_connection_status" {
  description = "Status of the CodeStar connection (must be AVAILABLE before pipeline works)"
  value       = module.codestar.connection_status
}

# CodePipeline Outputs
output "pipeline_name" {
  description = "Name of the CodePipeline"
  value       = module.codepipeline.pipeline_name
}

output "pipeline_console_url" {
  description = "AWS Console URL for the CodePipeline"
  value       = "https://${var.aws_region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${module.codepipeline.pipeline_name}/view"
}

# CodeBuild Outputs
output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = module.codebuild.project_name
}

# CodeDeploy Outputs
output "codedeploy_application_name" {
  description = "Name of the CodeDeploy application"
  value       = module.codedeploy.application_name
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = module.codedeploy.deployment_group_name
}

# Important Notes
output "important_notes" {
  description = "Important steps to complete after terraform apply"
  value       = <<-EOT
    
    ============================================================
    IMPORTANT: Complete these steps after terraform apply
    ============================================================
    
    1. AUTHORIZE GITHUB CONNECTION (Required):
       - Go to: AWS Console > Developer Tools > Connections
       - Find: ${module.codestar.connection_arn}
       - Click "Update pending connection"
       - Complete the GitHub OAuth authorization
       - Status must change from "PENDING" to "AVAILABLE"
    
    2. VERIFY EC2 INSTANCE:
       - Wait 3-5 minutes for user data script to complete
       - SSH: ssh -i your-key.pem ec2-user@${module.ec2.instance_public_ip}
       - Check Docker: docker --version
       - Check CodeDeploy: sudo systemctl status codedeploy-agent
    
    3. TRIGGER PIPELINE:
       - Push a commit to your GitHub repository, OR
       - Go to CodePipeline console and click "Release change"
    
    4. ACCESS APPLICATION:
       - URL: http://${module.ec2.instance_public_ip}:8000
    
    ============================================================
  EOT
}
