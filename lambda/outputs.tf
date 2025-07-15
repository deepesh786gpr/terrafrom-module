# Lambda Module Outputs

output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = aws_lambda_function.main.arn
}

output "lambda_function_name" {
  description = "The name of the Lambda Function"
  value       = aws_lambda_function.main.function_name
}

output "lambda_function_qualified_arn" {
  description = "The qualified ARN of the Lambda Function"
  value       = aws_lambda_function.main.qualified_arn
}

output "lambda_function_version" {
  description = "Latest published version of the Lambda Function"
  value       = aws_lambda_function.main.version
}

output "lambda_function_last_modified" {
  description = "The date the Lambda Function was last modified"
  value       = aws_lambda_function.main.last_modified
}

output "lambda_function_kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt environment variables"
  value       = aws_lambda_function.main.kms_key_arn
}

output "lambda_function_source_code_hash" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip file"
  value       = aws_lambda_function.main.source_code_hash
}

output "lambda_function_source_code_size" {
  description = "The size in bytes of the function .zip file"
  value       = aws_lambda_function.main.source_code_size
}

output "lambda_function_invoke_arn" {
  description = "The Invoke ARN of the Lambda Function"
  value       = aws_lambda_function.main.invoke_arn
}

output "lambda_function_url" {
  description = "The HTTP URL endpoint for the function in the format https://<url_id>.lambda-url.<region>.on.aws/"
  value       = try(aws_lambda_function_url.main[0].function_url, "")
}

output "lambda_function_url_id" {
  description = "The Lambda Function URL generated id"
  value       = try(aws_lambda_function_url.main[0].url_id, "")
}

output "lambda_alias_arn" {
  description = "The ARN of the Lambda alias"
  value       = try(aws_lambda_alias.main[0].arn, "")
}

output "lambda_alias_invoke_arn" {
  description = "The ARN to be used for invoking Lambda Function from API Gateway"
  value       = try(aws_lambda_alias.main[0].invoke_arn, "")
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role created for the Lambda Function"
  value       = aws_iam_role.lambda.arn
}

output "lambda_role_name" {
  description = "The name of the IAM role created for the Lambda Function"
  value       = aws_iam_role.lambda.name
}

output "lambda_role_unique_id" {
  description = "The unique ID of the IAM role created for the Lambda Function"
  value       = aws_iam_role.lambda.unique_id
}

output "lambda_security_group_id" {
  description = "The ID of the security group"
  value       = try(aws_security_group.lambda[0].id, "")
}

output "lambda_security_group_arn" {
  description = "The ARN of the security group"
  value       = try(aws_security_group.lambda[0].arn, "")
}

output "lambda_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group"
  value       = try(aws_cloudwatch_log_group.lambda[0].name, "")
}

output "lambda_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group"
  value       = try(aws_cloudwatch_log_group.lambda[0].arn, "")
}

output "kms_key_id" {
  description = "The KMS key ID used for encryption"
  value       = try(aws_kms_key.lambda[0].key_id, "")
}

output "kms_key_arn" {
  description = "The KMS key ARN used for encryption"
  value       = try(aws_kms_key.lambda[0].arn, "")
}

output "kms_alias_name" {
  description = "The KMS alias name"
  value       = try(aws_kms_alias.lambda[0].name, "")
}

output "kms_alias_arn" {
  description = "The KMS alias ARN"
  value       = try(aws_kms_alias.lambda[0].arn, "")
}

# Additional useful outputs
output "lambda_function_runtime" {
  description = "The runtime environment for the Lambda function"
  value       = aws_lambda_function.main.runtime
}

output "lambda_function_handler" {
  description = "The function entrypoint in your code"
  value       = aws_lambda_function.main.handler
}

output "lambda_function_memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  value       = aws_lambda_function.main.memory_size
}

output "lambda_function_timeout" {
  description = "The amount of time your Lambda Function has to run in seconds"
  value       = aws_lambda_function.main.timeout
}

output "lambda_function_environment" {
  description = "The Lambda environment's configuration settings"
  value       = aws_lambda_function.main.environment
  sensitive   = true
}

output "lambda_function_vpc_config" {
  description = "The VPC configuration of the Lambda function"
  value       = aws_lambda_function.main.vpc_config
}

output "lambda_function_dead_letter_config" {
  description = "The dead letter queue configuration of the Lambda function"
  value       = aws_lambda_function.main.dead_letter_config
}

output "lambda_function_tracing_config" {
  description = "The tracing configuration of the Lambda function"
  value       = aws_lambda_function.main.tracing_config
}

output "lambda_function_layers" {
  description = "List of Lambda Layer Version ARNs attached to your Lambda Function"
  value       = aws_lambda_function.main.layers
}

output "lambda_function_file_system_config" {
  description = "The connection settings for an EFS file system"
  value       = aws_lambda_function.main.file_system_config
}

output "lambda_function_image_config" {
  description = "Container image configuration values that override the values in the container image Dockerfile"
  value       = aws_lambda_function.main.image_config
}

output "lambda_function_ephemeral_storage" {
  description = "The amount of ephemeral storage (/tmp) allocated for the Lambda Function"
  value       = aws_lambda_function.main.ephemeral_storage
}

output "lambda_function_reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this lambda function"
  value       = aws_lambda_function.main.reserved_concurrent_executions
}
