# Terraform AWS Modules

A collection of production-ready Terraform modules for AWS infrastructure. These modules are designed to be reusable, secure, and follow AWS best practices.

## 🚀 Available Modules

| Module | Description | Version | Status |
|--------|-------------|---------|--------|
| [VPC](./vpc/) | Virtual Private Cloud with subnets, NAT gateways, and routing | v1.0.0 | ✅ Ready |
| [EC2](./ec2/) | EC2 instances with Auto Scaling Groups and security | v1.0.0 | ✅ Ready |
| [S3](./s3/) | S3 buckets with encryption, versioning, and lifecycle | v1.0.0 | ✅ Ready |
| [RDS](./rds/) | Relational Database Service with high availability | v1.0.0 | ✅ Ready |
| [EKS](./eks/) | Elastic Kubernetes Service with managed node groups | v1.0.0 | ✅ Ready |
| [Lambda](./lambda/) | Lambda functions with VPC support and monitoring | v1.0.0 | ✅ Ready |

## 📋 Features

### 🔒 Security First
- **Encryption**: KMS encryption for data at rest and in transit
- **IAM Roles**: Least privilege access with custom policies
- **Security Groups**: Restrictive network access controls
- **VPC**: Private subnets and secure networking

### 🏗️ Production Ready
- **High Availability**: Multi-AZ deployments
- **Auto Scaling**: Automatic scaling based on demand
- **Monitoring**: CloudWatch logs and metrics
- **Backup**: Automated backup and recovery

### 🔧 Configurable
- **Variables**: Extensive customization options
- **Outputs**: Comprehensive output values
- **Tags**: Consistent resource tagging
- **Validation**: Input validation and error handling

## 🚀 Quick Start

### 1. VPC Infrastructure
```hcl
module "vpc" {
  source = "github.com/deepesh786gpr/terraform-module//vpc"

  vpc_name = "production-vpc"
  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### 2. Application Infrastructure
```hcl
# Database
module "database" {
  source = "github.com/deepesh786gpr/terraform-module//rds"

  identifier = "app-database"
  engine     = "postgres"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  multi_az = true
  backup_retention_period = 30
  
  tags = {
    Environment = "production"
  }
}

# Application Servers
module "app_servers" {
  source = "github.com/deepesh786gpr/terraform-module//ec2"

  name       = "app-server"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  use_launch_template = true
  create_asg          = true
  min_size            = 2
  max_size            = 10
  desired_capacity    = 3

  tags = {
    Environment = "production"
  }
}

# File Storage
module "app_storage" {
  source = "github.com/deepesh786gpr/terraform-module//s3"

  bucket_name = "my-app-storage"
  versioning_enabled = true
  
  lifecycle_rules = [
    {
      id     = "transition_to_ia"
      status = "Enabled"
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        }
      ]
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### 3. Kubernetes Infrastructure
```hcl
module "eks_cluster" {
  source = "github.com/deepesh786gpr/terraform-module//eks"

  cluster_name = "production-cluster"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets

  node_groups = {
    main = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 10
      desired_size   = 3
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### 4. Serverless Functions
```hcl
module "api_function" {
  source = "github.com/deepesh786gpr/terraform-module//lambda"

  function_name = "api-handler"
  runtime       = "python3.9"
  
  create_package = true
  source_path    = "./lambda_code"
  
  create_function_url = true
  
  environment_variables = {
    DB_ENDPOINT = module.database.db_instance_endpoint
  }

  tags = {
    Environment = "production"
  }
}
```

## 📚 Module Documentation

Each module includes comprehensive documentation:

- **README.md**: Usage examples and configuration options
- **variables.tf**: Input variables with descriptions and validation
- **outputs.tf**: Output values for integration with other modules
- **main.tf**: Resource definitions and logic

## 🏷️ Tagging Strategy

All modules support consistent tagging:

```hcl
tags = {
  Environment = "production"
  Project     = "my-app"
  Owner       = "platform-team"
  Terraform   = "true"
  Module      = "vpc"
}
```

## 🔧 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## 📖 Best Practices

### 1. Version Pinning
```hcl
module "vpc" {
  source = "github.com/deepesh786gpr/terraform-module//vpc?ref=v1.0.0"
  # ... configuration
}
```

### 2. Environment Separation
```hcl
# environments/production/main.tf
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_name = "production-vpc"
  # ... production configuration
}

# environments/staging/main.tf
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_name = "staging-vpc"
  # ... staging configuration
}
```

### 3. Remote State
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "production/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests and documentation
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📖 [Documentation](https://github.com/deepesh786gpr/terraform-module)
- 🐛 [Issues](https://github.com/deepesh786gpr/terraform-module/issues)
- 💬 [Discussions](https://github.com/deepesh786gpr/terraform-module/discussions)

## 🎯 Roadmap

- [ ] ALB/NLB Module
- [ ] CloudFront Module
- [ ] Route53 Module
- [ ] ElastiCache Module
- [ ] SQS/SNS Module
- [ ] API Gateway Module

---

**Made with ❤️ for the DevOps community**
