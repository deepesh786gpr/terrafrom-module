# S3 Module Outputs

output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region"
  value       = aws_s3_bucket.main.hosted_zone_id
}

output "bucket_region" {
  description = "The AWS region this bucket resides in"
  value       = aws_s3_bucket.main.region
}

output "bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website"
  value       = try(aws_s3_bucket_website_configuration.main[0].website_endpoint, "")
}

output "bucket_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website"
  value       = try(aws_s3_bucket_website_configuration.main[0].website_domain, "")
}

output "bucket_versioning_status" {
  description = "The versioning state of the bucket"
  value       = aws_s3_bucket_versioning.main.versioning_configuration[0].status
}

output "bucket_encryption_algorithm" {
  description = "The server-side encryption algorithm used"
  value       = aws_s3_bucket_server_side_encryption_configuration.main.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm
}

output "bucket_kms_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption"
  value       = try(aws_s3_bucket_server_side_encryption_configuration.main.rule[0].apply_server_side_encryption_by_default[0].kms_master_key_id, "")
}

output "bucket_public_access_block" {
  description = "The public access block configuration"
  value = {
    block_public_acls       = aws_s3_bucket_public_access_block.main.block_public_acls
    block_public_policy     = aws_s3_bucket_public_access_block.main.block_public_policy
    ignore_public_acls      = aws_s3_bucket_public_access_block.main.ignore_public_acls
    restrict_public_buckets = aws_s3_bucket_public_access_block.main.restrict_public_buckets
  }
}

output "bucket_acl" {
  description = "The ACL of the bucket"
  value       = try(aws_s3_bucket_acl.main[0].acl, "")
}

output "bucket_object_ownership" {
  description = "The object ownership setting for the bucket"
  value       = aws_s3_bucket_ownership_controls.main.rule[0].object_ownership
}

output "bucket_lifecycle_configuration_rules" {
  description = "The lifecycle configuration rules"
  value       = try(aws_s3_bucket_lifecycle_configuration.main[0].rule, [])
}

output "bucket_cors_rules" {
  description = "The CORS configuration rules"
  value       = try(aws_s3_bucket_cors_configuration.main[0].cors_rule, [])
}

output "bucket_logging_target_bucket" {
  description = "The target bucket for access logs"
  value       = try(aws_s3_bucket_logging.main[0].target_bucket, "")
}

output "bucket_logging_target_prefix" {
  description = "The target prefix for access logs"
  value       = try(aws_s3_bucket_logging.main[0].target_prefix, "")
}

output "bucket_notification_configuration" {
  description = "The notification configuration"
  value = {
    topic_configurations  = try(aws_s3_bucket_notification.main[0].topic, [])
    queue_configurations  = try(aws_s3_bucket_notification.main[0].queue, [])
    lambda_configurations = try(aws_s3_bucket_notification.main[0].lambda_function, [])
  }
}

output "bucket_policy" {
  description = "The bucket policy"
  value       = try(aws_s3_bucket_policy.main[0].policy, "")
}

output "bucket_tags" {
  description = "The tags assigned to the bucket"
  value       = aws_s3_bucket.main.tags
}
