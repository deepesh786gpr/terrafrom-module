# RDS Module Outputs

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = aws_db_instance.main.hosted_zone_id
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = aws_db_instance.main.resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.main.status
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = var.manage_master_user_password ? null : (var.master_password != null ? var.master_password : try(random_password.master_password[0].result, null))
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.main.port
}

output "db_instance_address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.main.address
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = aws_db_instance.main.availability_zone
}

output "db_instance_backup_retention_period" {
  description = "The backup retention period"
  value       = aws_db_instance.main.backup_retention_period
}

output "db_instance_backup_window" {
  description = "The backup window"
  value       = aws_db_instance.main.backup_window
}

output "db_instance_ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  value       = aws_db_instance.main.ca_cert_identifier
}

output "db_instance_domain" {
  description = "The ID of the Directory Service Active Directory domain the instance is joined to"
  value       = aws_db_instance.main.domain
}

output "db_instance_domain_iam_role_name" {
  description = "The name of the IAM role to be used when making API calls to the Directory Service"
  value       = aws_db_instance.main.domain_iam_role_name
}

output "db_instance_engine" {
  description = "The database engine"
  value       = aws_db_instance.main.engine
}

output "db_instance_engine_version" {
  description = "The running version of the database"
  value       = aws_db_instance.main.engine_version
}

output "db_instance_maintenance_window" {
  description = "The instance maintenance window"
  value       = aws_db_instance.main.maintenance_window
}

output "db_instance_multi_az" {
  description = "If the RDS instance is multi AZ enabled"
  value       = aws_db_instance.main.multi_az
}

output "db_instance_class" {
  description = "The RDS instance class"
  value       = aws_db_instance.main.instance_class
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = try(aws_db_subnet_group.main[0].id, "")
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = try(aws_db_subnet_group.main[0].arn, "")
}

output "db_parameter_group_id" {
  description = "The db parameter group id"
  value       = try(aws_db_parameter_group.main[0].id, "")
}

output "db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = try(aws_db_parameter_group.main[0].arn, "")
}

output "db_option_group_id" {
  description = "The db option group id"
  value       = try(aws_db_option_group.main[0].id, "")
}

output "db_option_group_arn" {
  description = "The ARN of the db option group"
  value       = try(aws_db_option_group.main[0].arn, "")
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = try(aws_security_group.rds[0].id, "")
}

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = try(aws_security_group.rds[0].arn, "")
}

output "kms_key_id" {
  description = "The KMS key ID used for encryption"
  value       = try(aws_kms_key.rds[0].key_id, "")
}

output "kms_key_arn" {
  description = "The KMS key ARN used for encryption"
  value       = try(aws_kms_key.rds[0].arn, "")
}

output "kms_alias_name" {
  description = "The KMS alias name"
  value       = try(aws_kms_alias.rds[0].name, "")
}

output "kms_alias_arn" {
  description = "The KMS alias ARN"
  value       = try(aws_kms_alias.rds[0].arn, "")
}

output "enhanced_monitoring_iam_role_name" {
  description = "The name of the monitoring role"
  value       = aws_db_instance.main.monitoring_role_arn
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the monitoring role"
  value       = aws_db_instance.main.monitoring_role_arn
}

output "db_instance_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = aws_db_instance.main.enabled_cloudwatch_logs_exports
}
