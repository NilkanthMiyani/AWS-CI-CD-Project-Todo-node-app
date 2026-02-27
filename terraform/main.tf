# Root Module - Orchestrates all modules

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
  allowed_ssh_cidr   = var.allowed_ssh_cidr
}

# S3 Module
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

# CodeStar Connection Module (creates GitHub connection)
module "codestar" {
  source = "./modules/codestar"

  project_name = var.project_name
  environment  = var.environment
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name            = var.project_name
  environment             = var.environment
  s3_bucket_arn           = module.s3.bucket_arn
  codestar_connection_arn = module.codestar.connection_arn
}

# SSM Module
module "ssm" {
  source = "./modules/ssm"

  project_name        = var.project_name
  environment         = var.environment
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_registry_url = var.docker_registry_url
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  project_name          = var.project_name
  environment           = var.environment
  instance_type         = var.ec2_instance_type
  key_name              = var.ec2_key_name
  subnet_id             = module.vpc.public_subnet_id
  security_group_id     = module.vpc.ec2_security_group_id
  instance_profile_name = module.iam.ec2_instance_profile_name
  aws_region            = var.aws_region

  depends_on = [module.iam]
}

# CodeBuild Module
module "codebuild" {
  source = "./modules/codebuild"

  project_name           = var.project_name
  environment            = var.environment
  codebuild_role_arn     = module.iam.codebuild_role_arn
  s3_bucket_name         = module.s3.bucket_name
  docker_image_repo_name = var.docker_image_repo_name
  docker_image_tag       = var.docker_image_tag

  depends_on = [module.iam, module.s3, module.ssm]
}

# CodeDeploy Module
module "codedeploy" {
  source = "./modules/codedeploy"

  project_name        = var.project_name
  environment         = var.environment
  codedeploy_role_arn = module.iam.codedeploy_role_arn

  depends_on = [module.iam, module.ec2]
}

# CodePipeline Module
module "codepipeline" {
  source = "./modules/codepipeline"

  project_name                     = var.project_name
  environment                      = var.environment
  codepipeline_role_arn            = module.iam.codepipeline_role_arn
  s3_bucket_name                   = module.s3.bucket_name
  codestar_connection_arn          = module.codestar.connection_arn
  github_repo_owner                = var.github_repo_owner
  github_repo_name                 = var.github_repo_name
  github_branch                    = var.github_branch
  codebuild_project_name           = module.codebuild.project_name
  codedeploy_app_name              = module.codedeploy.application_name
  codedeploy_deployment_group_name = module.codedeploy.deployment_group_name

  depends_on = [module.codebuild, module.codedeploy, module.codestar]
}
