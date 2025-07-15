# S3 Module Variables

variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "use_random_suffix" {
  description = "Whether to add a random suffix to the bucket name for uniqueness"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "SSE algorithm must be AES256 or aws:kms."
  }
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS"
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "acl" {
  description = "The canned ACL to apply"
  type        = string
  default     = null
}

variable "object_ownership" {
  description = "Object ownership setting for the bucket"
  type        = string
  default     = "BucketOwnerPreferred"
  validation {
    condition     = contains(["BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"], var.object_ownership)
    error_message = "Object ownership must be BucketOwnerPreferred, ObjectWriter, or BucketOwnerEnforced."
  }
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type = list(object({
    id     = string
    status = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    expiration = optional(object({
      days                         = optional(number)
      date                         = optional(string)
      expired_object_delete_marker = optional(bool)
    }))
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }))
    transitions = optional(list(object({
      days          = optional(number)
      date          = optional(string)
      storage_class = string
    })))
    noncurrent_version_transitions = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })))
  }))
  default = []
}

variable "cors_rules" {
  description = "List of CORS rules for the bucket"
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "website_configuration" {
  description = "Website configuration for the bucket"
  type = object({
    index_document = optional(object({
      suffix = string
    }))
    error_document = optional(object({
      key = string
    }))
    redirect_all_requests_to = optional(object({
      host_name = string
      protocol  = optional(string)
    }))
    routing_rules = optional(list(object({
      condition = optional(object({
        http_error_code_returned_equals = optional(string)
        key_prefix_equals               = optional(string)
      }))
      redirect = object({
        host_name               = optional(string)
        http_redirect_code      = optional(string)
        protocol                = optional(string)
        replace_key_prefix_with = optional(string)
        replace_key_with        = optional(string)
      })
    })))
  })
  default = null
}

variable "logging_configuration" {
  description = "Logging configuration for the bucket"
  type = object({
    target_bucket = string
    target_prefix = optional(string)
  })
  default = null
}

variable "notification_configuration" {
  description = "Notification configuration for the bucket"
  type = object({
    topic_configurations = optional(list(object({
      topic_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })))
    queue_configurations = optional(list(object({
      queue_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })))
    lambda_configurations = optional(list(object({
      lambda_function_arn = string
      events              = list(string)
      filter_prefix       = optional(string)
      filter_suffix       = optional(string)
    })))
  })
  default = null
}

variable "bucket_policy" {
  description = "A valid bucket policy JSON document"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}
