# Lambda Module Variables

variable "function_name" {
  description = "A unique name for your Lambda Function"
  type        = string
}

variable "description" {
  description = "Description of your Lambda Function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
}

variable "package_type" {
  description = "The Lambda deployment package type"
  type        = string
  default     = "Zip"
  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "Package type must be Zip or Image."
  }
}

# Code configuration
variable "create_package" {
  description = "Whether to create a deployment package from source_path"
  type        = bool
  default     = false
}

variable "source_path" {
  description = "The path to the directory containing the Lambda function source code"
  type        = string
  default     = null
}

variable "filename" {
  description = "The path to the function's deployment package within the local filesystem"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Used to trigger updates when file contents change"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "The S3 bucket location containing the function's deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "The S3 key of an object containing the function's deployment package"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "The object version containing the function's deployment package"
  type        = string
  default     = null
}

variable "image_uri" {
  description = "The URI of the container image"
  type        = string
  default     = null
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs to attach to your Lambda Function"
  type        = list(string)
  default     = []
}

# Environment configuration
variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function"
  type        = map(string)
  default     = null
}

# VPC configuration
variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type = object({
    vpc_id             = string
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "create_security_group" {
  description = "Whether to create a security group for the Lambda function"
  type        = bool
  default     = true
}

variable "security_group_ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

# IAM configuration
variable "additional_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

variable "custom_policy_json" {
  description = "Custom IAM policy JSON to attach to the Lambda role"
  type        = string
  default     = null
}

# Encryption configuration
variable "create_kms_key" {
  description = "Whether to create a KMS key for Lambda encryption"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt environment variables"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "The ARN of the KMS key used to encrypt logs"
  type        = string
  default     = null
}

variable "kms_key_deletion_window" {
  description = "The waiting period, specified in number of days"
  type        = number
  default     = 7
}

# Logging configuration
variable "create_log_group" {
  description = "Whether to create a CloudWatch log group for the Lambda function"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events"
  type        = number
  default     = 14
}

# Dead letter queue configuration
variable "dead_letter_target_arn" {
  description = "The ARN of an SQS queue or SNS topic for dead letter queue"
  type        = string
  default     = null
}

# Tracing configuration
variable "tracing_mode" {
  description = "Tracing mode of the Lambda function"
  type        = string
  default     = null
  validation {
    condition     = var.tracing_mode == null || contains(["Active", "PassThrough"], var.tracing_mode)
    error_message = "Tracing mode must be Active or PassThrough."
  }
}

# File system configuration
variable "file_system_config" {
  description = "The connection settings for an EFS file system"
  type = object({
    arn              = string
    local_mount_path = string
  })
  default = null
}

# Image configuration (for container images)
variable "image_config" {
  description = "Container image configuration values that override the values in the container image Dockerfile"
  type = object({
    command           = optional(list(string))
    entry_point       = optional(list(string))
    working_directory = optional(string)
  })
  default = null
}

# Ephemeral storage
variable "ephemeral_storage_size" {
  description = "The amount of ephemeral storage (/tmp) to allocate for the Lambda Function in MB"
  type        = number
  default     = null
  validation {
    condition     = var.ephemeral_storage_size == null || (var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240)
    error_message = "Ephemeral storage size must be between 512 and 10240 MB."
  }
}

# Concurrency configuration
variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this lambda function"
  type        = number
  default     = -1
}

# Publishing configuration
variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version"
  type        = bool
  default     = false
}

# Function URL configuration
variable "create_function_url" {
  description = "Whether to create a Lambda Function URL"
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "The type of authentication that the function URL uses"
  type        = string
  default     = "AWS_IAM"
  validation {
    condition     = contains(["AWS_IAM", "NONE"], var.function_url_auth_type)
    error_message = "Function URL auth type must be AWS_IAM or NONE."
  }
}

variable "function_url_cors" {
  description = "The CORS configuration for the function URL"
  type = object({
    allow_credentials = optional(bool)
    allow_headers     = optional(list(string))
    allow_methods     = optional(list(string))
    allow_origins     = optional(list(string))
    expose_headers    = optional(list(string))
    max_age           = optional(number)
  })
  default = null
}

# Alias configuration
variable "create_alias" {
  description = "Whether to create a Lambda alias"
  type        = bool
  default     = false
}

variable "alias_name" {
  description = "Name for the alias"
  type        = string
  default     = "live"
}

variable "alias_description" {
  description = "Description of the alias"
  type        = string
  default     = ""
}

variable "alias_function_version" {
  description = "Lambda function version for which you are creating the alias"
  type        = string
  default     = "$LATEST"
}

variable "alias_routing_config" {
  description = "The Lambda alias routing configuration"
  type = object({
    additional_version_weights = map(number)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}
