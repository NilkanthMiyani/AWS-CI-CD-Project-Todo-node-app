output "docker_username_parameter_arn" {
  description = "ARN of the Docker username SSM parameter"
  value       = aws_ssm_parameter.docker_username.arn
}

output "docker_password_parameter_arn" {
  description = "ARN of the Docker password SSM parameter"
  value       = aws_ssm_parameter.docker_password.arn
}

output "docker_registry_url_parameter_arn" {
  description = "ARN of the Docker registry URL SSM parameter"
  value       = aws_ssm_parameter.docker_registry_url.arn
}
