# VPC Terraform Module

This module creates a production-ready VPC with public and private subnets across multiple availability zones.

## Features

- **Multi-AZ Setup**: Subnets across multiple availability zones for high availability
- **Public Subnets**: For load balancers, bastion hosts, and NAT gateways
- **Private Subnets**: For application servers and internal resources
- **Database Subnets**: Dedicated subnets for RDS instances
- **NAT Gateways**: For outbound internet access from private subnets
- **Internet Gateway**: For public subnet internet access
- **Route Tables**: Properly configured routing for each subnet tier
- **VPC Flow Logs**: Optional VPC flow logging for security monitoring
- **Security**: Default security group with no rules for security

## Usage

```hcl
module "vpc" {
  source = "./vpc"

  vpc_name = "my-production-vpc"
  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  database_subnet_cidrs = ["10.0.100.0/24", "10.0.200.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Environment = "production"
    Project     = "my-project"
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
| vpc_name | Name of the VPC | `string` | n/a | yes |
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| public_subnet_cidrs | CIDR blocks for public subnets | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` | no |
| private_subnet_cidrs | CIDR blocks for private subnets | `list(string)` | `["10.0.10.0/24", "10.0.20.0/24"]` | no |
| database_subnet_cidrs | CIDR blocks for database subnets | `list(string)` | `["10.0.100.0/24", "10.0.200.0/24"]` | no |
| create_database_subnets | Whether to create database subnets | `bool` | `true` | no |
| enable_nat_gateway | Should be true to provision NAT Gateways | `bool` | `true` | no |
| single_nat_gateway | Should be true to provision a single shared NAT Gateway | `bool` | `false` | no |
| enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| enable_flow_logs | Whether to enable VPC Flow Logs | `bool` | `false` | no |
| tags | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| public_subnets | List of IDs of public subnets |
| private_subnets | List of IDs of private subnets |
| database_subnets | List of IDs of database subnets |
| database_subnet_group | ID of database subnet group |
| internet_gateway_id | The ID of the Internet Gateway |
| nat_ids | List of IDs of the NAT Gateways |
| nat_public_ips | List of public Elastic IPs created for AWS NAT Gateway |

## Examples

### Basic VPC
```hcl
module "vpc" {
  source = "./vpc"

  vpc_name = "basic-vpc"
  vpc_cidr = "10.0.0.0/16"
}
```

### VPC without NAT Gateway
```hcl
module "vpc" {
  source = "./vpc"

  vpc_name = "simple-vpc"
  vpc_cidr = "10.0.0.0/16"
  
  enable_nat_gateway = false
}
```

### VPC with Single NAT Gateway
```hcl
module "vpc" {
  source = "./vpc"

  vpc_name = "cost-optimized-vpc"
  vpc_cidr = "10.0.0.0/16"
  
  enable_nat_gateway = true
  single_nat_gateway = true
}
```
