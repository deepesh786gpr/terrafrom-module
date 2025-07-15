# EKS Terraform Module

This module creates production-ready EKS clusters with managed node groups, security groups, and IAM roles.

## Features

- **EKS Cluster**: Fully managed Kubernetes control plane
- **Managed Node Groups**: Auto-scaling worker nodes
- **Security**: VPC security groups and IAM roles
- **Encryption**: KMS encryption for secrets
- **Logging**: CloudWatch control plane logging
- **Add-ons**: Core EKS add-ons (CoreDNS, kube-proxy, VPC CNI)
- **Multi-AZ**: High availability across availability zones

## Usage

### Basic EKS Cluster
```hcl
module "eks" {
  source = "./eks"

  cluster_name    = "my-app-cluster"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Node groups
  node_groups = {
    main = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 5
      desired_size   = 3
    }
  }

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Production EKS Cluster
```hcl
module "eks_production" {
  source = "./eks"

  cluster_name    = "production-cluster"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Cluster configuration
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_endpoint_public_access_cidrs = ["10.0.0.0/8"]

  # Encryption
  create_kms_key = true
  cluster_encryption_config = [
    {
      provider_key_arn = ""  # Will use created KMS key
      resources        = ["secrets"]
    }
  ]

  # Logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Node groups
  node_groups = {
    general = {
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 10
      desired_size   = 4
      
      labels = {
        role = "general"
      }
    }
    
    spot = {
      instance_types = ["t3.large", "t3a.large", "t2.large"]
      capacity_type  = "SPOT"
      min_size       = 0
      max_size       = 5
      desired_size   = 2
      
      labels = {
        role = "spot"
      }
      
      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  # Add-ons
  cluster_addons = {
    coredns = {
      addon_version = "v1.10.1-eksbuild.1"
    }
    kube-proxy = {
      addon_version = "v1.27.1-eksbuild.1"
    }
    vpc-cni = {
      addon_version = "v1.12.6-eksbuild.2"
    }
  }

  tags = {
    Environment = "production"
    Monitoring  = "enabled"
  }
}
```

### EKS with Custom Launch Template
```hcl
resource "aws_launch_template" "custom" {
  name_prefix   = "eks-custom-"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = "t3.medium"

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    cluster_name = "my-cluster"
  }))

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp3"
      encrypted   = true
    }
  }

  tags = {
    Name = "eks-custom-launch-template"
  }
}

module "eks_custom" {
  source = "./eks"

  cluster_name = "custom-cluster"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets

  node_groups = {
    custom = {
      launch_template = {
        id      = aws_launch_template.custom.id
        version = "$Latest"
      }
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    Environment = "production"
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
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| cluster_version | Kubernetes version to use for the EKS cluster | `string` | `"1.27"` | no |
| vpc_id | ID of the VPC where to create security groups | `string` | n/a | yes |
| subnet_ids | A list of subnet IDs where the EKS cluster will be created | `list(string)` | n/a | yes |
| cluster_endpoint_private_access | Whether the Amazon EKS private API server endpoint is enabled | `bool` | `false` | no |
| cluster_endpoint_public_access | Whether the Amazon EKS public API server endpoint is enabled | `bool` | `true` | no |
| create_node_groups | Whether to create EKS managed node groups | `bool` | `true` | no |
| node_groups | Map of EKS managed node group definitions | `map(object)` | `{}` | no |
| cluster_addons | Map of cluster addon configurations | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The name/id of the EKS cluster |
| cluster_arn | The Amazon Resource Name (ARN) of the cluster |
| cluster_endpoint | Endpoint for EKS control plane |
| cluster_version | The Kubernetes version for the EKS cluster |
| cluster_certificate_authority_data | Base64 encoded certificate data |
| node_groups | Map of attribute maps for all EKS managed node groups |
| cluster_oidc_issuer_url | The URL on the EKS cluster for the OpenID Connect identity provider |

## Examples

### Multi-Environment Setup
```hcl
module "eks_dev" {
  source = "./eks"

  cluster_name = "dev-cluster"
  vpc_id       = module.vpc_dev.vpc_id
  subnet_ids   = module.vpc_dev.private_subnets

  node_groups = {
    dev = {
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 3
      desired_size   = 1
    }
  }

  tags = {
    Environment = "development"
  }
}

module "eks_prod" {
  source = "./eks"

  cluster_name = "prod-cluster"
  vpc_id       = module.vpc_prod.vpc_id
  subnet_ids   = module.vpc_prod.private_subnets

  cluster_endpoint_private_access = true
  create_kms_key = true

  node_groups = {
    prod = {
      instance_types = ["t3.large"]
      min_size       = 3
      max_size       = 10
      desired_size   = 5
    }
  }

  tags = {
    Environment = "production"
  }
}
```
