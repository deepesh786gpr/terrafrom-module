# Lambda Module - Production Ready
# Creates Lambda function with IAM roles, security groups, and optional triggers

# Data sources
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

# Archive file for Lambda function code
data "archive_file" "lambda_zip" {
  count = var.create_package && var.source_path != null ? 1 : 0

  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/${var.function_name}.zip"
}

# Lambda IAM Role
resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.function_name}-lambda-role"
    Type = "IAM Role"
  })
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}

# VPC execution policy (if Lambda is in VPC)
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = var.vpc_config != null ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda.name
}

# Additional IAM policies
resource "aws_iam_role_policy_attachment" "lambda_additional" {
  count = length(var.additional_policy_arns)

  policy_arn = var.additional_policy_arns[count.index]
  role       = aws_iam_role.lambda.name
}

# Custom IAM policy
resource "aws_iam_role_policy" "lambda_custom" {
  count = var.custom_policy_json != null ? 1 : 0

  name = "${var.function_name}-custom-policy"
  role = aws_iam_role.lambda.id

  policy = var.custom_policy_json
}

# Security Group for Lambda (if in VPC)
resource "aws_security_group" "lambda" {
  count = var.vpc_config != null && var.create_security_group ? 1 : 0

  name_prefix = "${var.function_name}-lambda-"
  vpc_id      = var.vpc_config.vpc_id
  description = "Security group for Lambda function ${var.function_name}"

  # Custom ingress rules
  dynamic "ingress" {
    for_each = var.security_group_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.function_name}-lambda-sg"
    Type = "Security Group"
  })
}

# KMS Key for Lambda environment variables encryption
resource "aws_kms_key" "lambda" {
  count = var.create_kms_key ? 1 : 0

  description             = "KMS key for Lambda function ${var.function_name}"
  deletion_window_in_days = var.kms_key_deletion_window

  tags = merge(var.tags, {
    Name = "${var.function_name}-lambda-kms-key"
    Type = "KMS Key"
  })
}

resource "aws_kms_alias" "lambda" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${var.function_name}-lambda"
  target_key_id = aws_kms_key.lambda[0].key_id
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.create_kms_key ? aws_kms_key.lambda[0].arn : var.kms_key_id

  tags = merge(var.tags, {
    Name = "${var.function_name}-log-group"
    Type = "CloudWatch Log Group"
  })
}

# Lambda Function
resource "aws_lambda_function" "main" {
  function_name = var.function_name
  description   = var.description
  role          = aws_iam_role.lambda.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  # Code configuration
  filename         = var.create_package && var.source_path != null ? data.archive_file.lambda_zip[0].output_path : var.filename
  source_code_hash = var.create_package && var.source_path != null ? data.archive_file.lambda_zip[0].output_base64sha256 : var.source_code_hash
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  s3_object_version = var.s3_object_version
  image_uri        = var.image_uri
  package_type     = var.package_type

  # Layers
  layers = var.layers

  # Environment variables
  dynamic "environment" {
    for_each = var.environment_variables != null ? [var.environment_variables] : []
    content {
      variables = environment.value
    }
  }

  # VPC configuration
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = var.create_security_group ? concat([aws_security_group.lambda[0].id], vpc_config.value.security_group_ids) : vpc_config.value.security_group_ids
    }
  }

  # Dead letter queue configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  # Tracing configuration
  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }

  # File system configuration
  dynamic "file_system_config" {
    for_each = var.file_system_config != null ? [var.file_system_config] : []
    content {
      arn              = file_system_config.value.arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  # Image configuration (for container images)
  dynamic "image_config" {
    for_each = var.image_config != null ? [var.image_config] : []
    content {
      command           = image_config.value.command
      entry_point       = image_config.value.entry_point
      working_directory = image_config.value.working_directory
    }
  }

  # Ephemeral storage
  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size != null ? [1] : []
    content {
      size = var.ephemeral_storage_size
    }
  }

  # KMS key for environment variables encryption
  kms_key_arn = var.create_kms_key ? aws_kms_key.lambda[0].arn : var.kms_key_arn

  # Reserved concurrent executions
  reserved_concurrent_executions = var.reserved_concurrent_executions

  # Publish version
  publish = var.publish

  tags = merge(var.tags, {
    Name = var.function_name
    Type = "Lambda Function"
  })

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc,
    aws_cloudwatch_log_group.lambda,
  ]
}

# Lambda Function URL (if enabled)
resource "aws_lambda_function_url" "main" {
  count = var.create_function_url ? 1 : 0

  function_name      = aws_lambda_function.main.function_name
  authorization_type = var.function_url_auth_type

  dynamic "cors" {
    for_each = var.function_url_cors != null ? [var.function_url_cors] : []
    content {
      allow_credentials = cors.value.allow_credentials
      allow_headers     = cors.value.allow_headers
      allow_methods     = cors.value.allow_methods
      allow_origins     = cors.value.allow_origins
      expose_headers    = cors.value.expose_headers
      max_age           = cors.value.max_age
    }
  }
}

# Lambda Alias
resource "aws_lambda_alias" "main" {
  count = var.create_alias ? 1 : 0

  name             = var.alias_name
  description      = var.alias_description
  function_name    = aws_lambda_function.main.function_name
  function_version = var.alias_function_version

  dynamic "routing_config" {
    for_each = var.alias_routing_config != null ? [var.alias_routing_config] : []
    content {
      additional_version_weights = routing_config.value.additional_version_weights
    }
  }
}
