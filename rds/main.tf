# RDS Module - Production Ready
# Creates RDS instance with security groups, parameter groups, and option groups

# Random password for database
resource "random_password" "master_password" {
  count   = var.manage_master_user_password ? 0 : (var.master_password == null ? 1 : 0)
  length  = var.random_password_length
  special = true
}

# KMS key for RDS encryption
resource "aws_kms_key" "rds" {
  count = var.create_kms_key ? 1 : 0

  description             = "KMS key for RDS encryption"
  deletion_window_in_days = var.kms_key_deletion_window

  tags = merge(var.tags, {
    Name = "${var.identifier}-kms-key"
    Type = "KMS Key"
  })
}

resource "aws_kms_alias" "rds" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${var.identifier}-rds"
  target_key_id = aws_kms_key.rds[0].key_id
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  count = var.create_db_subnet_group ? 1 : 0

  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = var.db_subnet_group_name
    Type = "DB Subnet Group"
  })
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  count = var.create_db_parameter_group ? 1 : 0

  family = var.family
  name   = var.parameter_group_name

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(var.tags, {
    Name = var.parameter_group_name
    Type = "DB Parameter Group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# DB Option Group
resource "aws_db_option_group" "main" {
  count = var.create_db_option_group ? 1 : 0

  name                     = var.option_group_name
  option_group_description = var.option_group_description
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version

  dynamic "option" {
    for_each = var.options
    content {
      option_name                    = option.value.option_name
      port                          = lookup(option.value, "port", null)
      version                       = lookup(option.value, "version", null)
      db_security_group_memberships = lookup(option.value, "db_security_group_memberships", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = var.option_group_name
    Type = "DB Option Group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.identifier}-rds-"
  vpc_id      = var.vpc_id
  description = "Security group for RDS instance ${var.identifier}"

  # Database access from allowed security groups
  dynamic "ingress" {
    for_each = var.allowed_security_groups
    content {
      from_port                = var.port
      to_port                  = var.port
      protocol                 = "tcp"
      source_security_group_id = ingress.value
      description              = "Database access from security group ${ingress.value}"
    }
  }

  # Database access from allowed CIDR blocks
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "Database access from allowed CIDR blocks"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-rds-sg"
    Type = "Security Group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = var.identifier

  # Engine configuration
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id           = var.storage_encrypted ? (var.create_kms_key ? aws_kms_key.rds[0].arn : var.kms_key_id) : null
  iops                 = var.iops
  storage_throughput   = var.storage_throughput

  # Database configuration
  db_name  = var.db_name
  username = var.username
  password = var.manage_master_user_password ? null : (var.master_password != null ? var.master_password : random_password.master_password[0].result)
  port     = var.port

  # Network configuration
  db_subnet_group_name   = var.create_db_subnet_group ? aws_db_subnet_group.main[0].name : var.db_subnet_group_name
  vpc_security_group_ids = var.create_security_group ? [aws_security_group.rds[0].id] : var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible

  # Parameter and option groups
  parameter_group_name = var.create_db_parameter_group ? aws_db_parameter_group.main[0].name : var.parameter_group_name
  option_group_name    = var.create_db_option_group ? aws_db_option_group.main[0].name : var.option_group_name

  # Backup configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  copy_tags_to_snapshot  = var.copy_tags_to_snapshot
  delete_automated_backups = var.delete_automated_backups

  # Maintenance configuration
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade

  # Monitoring configuration
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  # Security configuration
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Multi-AZ and read replica configuration
  multi_az               = var.multi_az
  availability_zone      = var.availability_zone
  replicate_source_db    = var.replicate_source_db

  # Character set and timezone
  character_set_name = var.character_set_name
  timezone          = var.timezone

  # License model
  license_model = var.license_model

  # Manage master user password
  manage_master_user_password = var.manage_master_user_password

  tags = merge(var.tags, {
    Name = var.identifier
    Type = "RDS Instance"
  })

  depends_on = [
    aws_db_subnet_group.main,
    aws_db_parameter_group.main,
    aws_db_option_group.main,
    aws_security_group.rds
  ]
}
