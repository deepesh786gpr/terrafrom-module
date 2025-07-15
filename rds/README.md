# RDS Terraform Module

This module creates production-ready RDS instances with security groups, parameter groups, and option groups.

## Features

- **Multi-Engine Support**: MySQL, PostgreSQL, Oracle, SQL Server
- **Security**: VPC security groups and encryption
- **High Availability**: Multi-AZ deployment support
- **Backup & Recovery**: Automated backups and point-in-time recovery
- **Monitoring**: Enhanced monitoring and Performance Insights
- **Parameter Groups**: Custom database parameter groups
- **Option Groups**: Database option groups for advanced features
- **Encryption**: KMS encryption for data at rest

## Usage

### Basic MySQL Database
```hcl
module "mysql_db" {
  source = "./rds"

  identifier = "my-app-db"
  engine     = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_encrypted = true

  db_name  = "myapp"
  username = "admin"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  allowed_security_groups = [module.app_server.security_group_id]

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### PostgreSQL with Custom Parameters
```hcl
module "postgres_db" {
  source = "./rds"

  identifier = "analytics-db"
  engine     = "postgres"
  engine_version = "14.9"
  instance_class = "db.r5.large"

  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = "analytics"
  username = "postgres"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Custom parameter group
  family = "postgres14"
  parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name  = "log_statement"
      value = "all"
    }
  ]

  # Multi-AZ for high availability
  multi_az = true

  # Enhanced monitoring
  monitoring_interval = 60
  performance_insights_enabled = true

  backup_retention_period = 30
  deletion_protection    = true

  tags = {
    Environment = "production"
    Purpose     = "analytics"
  }
}
```

### Read Replica
```hcl
module "read_replica" {
  source = "./rds"

  identifier = "my-app-db-replica"
  
  # Read replica configuration
  replicate_source_db = module.mysql_db.db_instance_id
  
  instance_class = "db.t3.small"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  allowed_security_groups = [module.read_only_app.security_group_id]

  tags = {
    Environment = "production"
    Type        = "read-replica"
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
| identifier | The name of the RDS instance | `string` | n/a | yes |
| engine | The database engine | `string` | `"mysql"` | no |
| engine_version | The engine version to use | `string` | `"8.0"` | no |
| instance_class | The instance type of the RDS instance | `string` | `"db.t3.micro"` | no |
| allocated_storage | The allocated storage in gigabytes | `number` | `20` | no |
| storage_encrypted | Specifies whether the DB instance is encrypted | `bool` | `true` | no |
| vpc_id | ID of the VPC where to create security group | `string` | n/a | yes |
| subnet_ids | A list of VPC subnet IDs | `list(string)` | n/a | yes |
| db_name | The name of the database to create | `string` | `null` | no |
| username | Username for the master DB user | `string` | `"admin"` | no |
| master_password | Password for the master DB user | `string` | `null` | no |
| backup_retention_period | The days to retain backups for | `number` | `7` | no |
| multi_az | Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| deletion_protection | The database can't be deleted when this value is set to true | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_endpoint | The RDS instance endpoint |
| db_instance_id | The RDS instance ID |
| db_instance_arn | The ARN of the RDS instance |
| db_instance_username | The master username for the database |
| db_instance_port | The database port |
| security_group_id | ID of the security group |

## Examples

### High Availability Production Database
```hcl
module "production_db" {
  source = "./rds"

  identifier = "prod-app-db"
  engine     = "postgres"
  engine_version = "14.9"
  instance_class = "db.r5.xlarge"

  allocated_storage     = 500
  max_allocated_storage = 2000
  storage_type         = "gp3"
  storage_encrypted    = true
  create_kms_key       = true

  db_name  = "production"
  username = "app_user"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # High availability
  multi_az = true
  
  # Security
  allowed_security_groups = [
    module.app_servers.security_group_id,
    module.admin_bastion.security_group_id
  ]

  # Backup and maintenance
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  deletion_protection    = true

  # Monitoring
  monitoring_interval = 60
  performance_insights_enabled = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Custom parameters
  family = "postgres14"
  parameters = [
    {
      name  = "log_statement"
      value = "all"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  ]

  tags = {
    Environment = "production"
    Backup      = "required"
    Monitoring  = "enhanced"
  }
}
```
