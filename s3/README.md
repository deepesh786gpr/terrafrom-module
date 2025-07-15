# S3 Terraform Module

This module creates production-ready S3 buckets with security, versioning, encryption, and lifecycle policies.

## Features

- **Security**: Public access blocking and configurable ACLs
- **Encryption**: Server-side encryption with AES256 or KMS
- **Versioning**: Object versioning support
- **Lifecycle**: Intelligent tiering and expiration policies
- **CORS**: Cross-origin resource sharing configuration
- **Website Hosting**: Static website hosting support
- **Logging**: Access logging configuration
- **Notifications**: Event notifications to SNS, SQS, or Lambda

## Usage

### Basic S3 Bucket
```hcl
module "s3_bucket" {
  source = "./s3"

  bucket_name = "my-app-storage"
  
  versioning_enabled = true
  sse_algorithm      = "AES256"

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### S3 Bucket with KMS Encryption
```hcl
module "s3_encrypted" {
  source = "./s3"

  bucket_name = "sensitive-data"
  
  versioning_enabled = true
  sse_algorithm      = "aws:kms"
  kms_master_key_id  = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  lifecycle_rules = [
    {
      id     = "transition_to_ia"
      status = "Enabled"
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  tags = {
    Environment = "production"
    Compliance  = "required"
  }
}
```

### Static Website Hosting
```hcl
module "website_bucket" {
  source = "./s3"

  bucket_name = "my-website"
  
  # Allow public read access for website
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  website_configuration = {
    index_document = {
      suffix = "index.html"
    }
    error_document = {
      key = "error.html"
    }
  }

  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://example.com"]
      max_age_seconds = 3000
    }
  ]

  tags = {
    Environment = "production"
    Type        = "website"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | The name of the bucket | `string` | n/a | yes |
| use_random_suffix | Whether to add a random suffix to bucket name | `bool` | `true` | no |
| versioning_enabled | Enable versioning for the S3 bucket | `bool` | `true` | no |
| sse_algorithm | The server-side encryption algorithm to use | `string` | `"AES256"` | no |
| kms_master_key_id | The AWS KMS master key ID for SSE-KMS | `string` | `null` | no |
| block_public_acls | Whether to block public ACLs | `bool` | `true` | no |
| block_public_policy | Whether to block public bucket policies | `bool` | `true` | no |
| ignore_public_acls | Whether to ignore public ACLs | `bool` | `true` | no |
| restrict_public_buckets | Whether to restrict public bucket policies | `bool` | `true` | no |
| lifecycle_rules | List of lifecycle rules for the bucket | `list(object)` | `[]` | no |
| cors_rules | List of CORS rules for the bucket | `list(object)` | `[]` | no |
| website_configuration | Website configuration for the bucket | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the bucket |
| bucket_arn | The ARN of the bucket |
| bucket_domain_name | The bucket domain name |
| bucket_website_endpoint | The website endpoint |
| bucket_versioning_status | The versioning state of the bucket |

## Examples

### Data Lake Bucket
```hcl
module "data_lake" {
  source = "./s3"

  bucket_name = "company-data-lake"
  
  versioning_enabled = true
  sse_algorithm      = "aws:kms"

  lifecycle_rules = [
    {
      id     = "data_lifecycle"
      status = "Enabled"
      filter = {
        prefix = "raw-data/"
      }
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      expiration = {
        days = 2555  # 7 years
      }
    }
  ]

  notification_configuration = {
    lambda_configurations = [
      {
        lambda_function_arn = aws_lambda_function.processor.arn
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = "incoming/"
      }
    ]
  }

  tags = {
    Environment = "production"
    Purpose     = "data-lake"
  }
}
```

### Backup Bucket
```hcl
module "backup_bucket" {
  source = "./s3"

  bucket_name = "application-backups"
  
  versioning_enabled = true
  sse_algorithm      = "aws:kms"

  lifecycle_rules = [
    {
      id     = "backup_retention"
      status = "Enabled"
      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
      expiration = {
        days = 365
      }
    }
  ]

  logging_configuration = {
    target_bucket = module.access_logs.bucket_id
    target_prefix = "backup-bucket-logs/"
  }

  tags = {
    Environment = "production"
    Purpose     = "backup"
  }
}
```
