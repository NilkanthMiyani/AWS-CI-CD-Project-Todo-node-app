# Data source for current AWS account
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
