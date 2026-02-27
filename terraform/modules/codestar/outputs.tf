output "connection_arn" {
  description = "ARN of the CodeStar connection"
  value       = aws_codestarconnections_connection.github.arn
}

output "connection_status" {
  description = "Status of the CodeStar connection"
  value       = aws_codestarconnections_connection.github.connection_status
}

output "connection_name" {
  description = "Name of the CodeStar connection"
  value       = aws_codestarconnections_connection.github.name
}
