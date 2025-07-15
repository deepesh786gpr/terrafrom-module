# EC2 Terraform Module

This module creates production-ready EC2 instances with security groups, IAM roles, and optional Auto Scaling Groups.

## Features

- **EC2 Instances**: Launch single or multiple EC2 instances
- **Auto Scaling Groups**: Optional ASG with launch templates
- **Security Groups**: Configurable security groups with custom rules
- **IAM Roles**: Instance profiles with customizable policies
- **Key Pairs**: SSH key pair management
- **EBS Volumes**: Root and additional EBS volume configuration
- **Monitoring**: CloudWatch detailed monitoring support
- **User Data**: Custom initialization scripts

## Usage

### Basic EC2 Instance
```hcl
module "ec2" {
  source = "./ec2"

  name                = "web-server"
  instance_count      = 2
  instance_type       = "t3.medium"
  vpc_id              = "vpc-12345678"
  subnet_ids          = ["subnet-12345678", "subnet-87654321"]
  
  enable_ssh_access   = true
  enable_http_access  = true
  enable_https_access = true

  tags = {
    Environment = "production"
    Project     = "web-app"
  }
}
```

### EC2 with Auto Scaling Group
```hcl
module "ec2_asg" {
  source = "./ec2"

  name                = "app-server"
  vpc_id              = "vpc-12345678"
  subnet_ids          = ["subnet-12345678", "subnet-87654321"]
  
  use_launch_template = true
  create_asg          = true
  min_size            = 2
  max_size            = 10
  desired_capacity    = 3

  instance_type       = "t3.large"
  enable_ssh_access   = true

  tags = {
    Environment = "production"
    Project     = "scalable-app"
  }
}
```

### EC2 with Custom IAM Role
```hcl
module "ec2_custom_iam" {
  source = "./ec2"

  name                = "data-processor"
  instance_count      = 1
  instance_type       = "c5.xlarge"
  vpc_id              = "vpc-12345678"
  subnet_ids          = ["subnet-12345678"]
  
  create_iam_role     = true
  iam_policy_arns     = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y aws-cli
    # Custom initialization script
  EOF
  )

  tags = {
    Environment = "production"
    Role        = "data-processing"
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
| name | Name to be used on EC2 instance created | `string` | n/a | yes |
| vpc_id | ID of the VPC where to create security group | `string` | n/a | yes |
| subnet_ids | A list of VPC subnet IDs to launch in | `list(string)` | n/a | yes |
| instance_count | Number of instances to launch | `number` | `1` | no |
| instance_type | The type of instance to start | `string` | `"t3.micro"` | no |
| ami_id | ID of AMI to use for the instance | `string` | `""` | no |
| associate_public_ip_address | Whether to associate a public IP address | `bool` | `false` | no |
| enable_ssh_access | Whether to enable SSH access | `bool` | `true` | no |
| enable_http_access | Whether to enable HTTP access | `bool` | `false` | no |
| enable_https_access | Whether to enable HTTPS access | `bool` | `false` | no |
| use_launch_template | Whether to use launch template | `bool` | `false` | no |
| create_asg | Whether to create Auto Scaling Group | `bool` | `false` | no |
| min_size | The minimum size of the auto scale group | `number` | `1` | no |
| max_size | The maximum size of the auto scale group | `number` | `3` | no |
| desired_capacity | The desired capacity of the auto scale group | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_ids | List of IDs of instances |
| instance_public_ips | List of public IP addresses |
| instance_private_ips | List of private IP addresses |
| security_group_id | ID of the security group |
| autoscaling_group_name | The autoscaling group name |
| launch_template_id | The ID of the launch template |

## Examples

### Web Server with Load Balancer
```hcl
module "web_servers" {
  source = "./ec2"

  name                = "web-server"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets
  
  use_launch_template = true
  create_asg          = true
  min_size            = 2
  max_size            = 6
  desired_capacity    = 3

  instance_type       = "t3.medium"
  enable_http_access  = true
  enable_https_access = true

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    app_version = "1.0.0"
  }))

  tags = {
    Environment = "production"
    Application = "web-app"
  }
}
```

### Database Server
```hcl
module "database_server" {
  source = "./ec2"

  name                = "database"
  instance_count      = 1
  instance_type       = "r5.large"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets
  
  create_iam_role     = true
  iam_policy_arns     = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  custom_ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "MySQL access from VPC"
    }
  ]

  ebs_block_devices = [
    {
      device_name           = "/dev/sdf"
      volume_size           = 100
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
      encrypted             = true
      delete_on_termination = false
    }
  ]

  tags = {
    Environment = "production"
    Role        = "database"
  }
}
```
