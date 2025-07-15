# EKS Module Variables

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.27"
}

variable "vpc_id" {
  description = "ID of the VPC where to create security groups"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster will be created"
  type        = list(string)
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_cluster_security_group" {
  description = "Whether to create a security group for the cluster"
  type        = bool
  default     = true
}

variable "cluster_security_group_ids" {
  description = "List of security group IDs for the cross-account elastic network interfaces"
  type        = list(string)
  default     = []
}

variable "cluster_additional_policies" {
  description = "List of additional IAM policy ARNs to attach to the cluster role"
  type        = list(string)
  default     = []
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}

variable "create_kms_key" {
  description = "Whether to create a KMS key for cluster encryption"
  type        = bool
  default     = false
}

variable "kms_key_deletion_window" {
  description = "The waiting period, specified in number of days"
  type        = number
  default     = 7
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "create_node_groups" {
  description = "Whether to create EKS managed node groups"
  type        = bool
  default     = true
}

variable "node_group_subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned"
  type        = list(string)
  default     = []
}

variable "create_node_group_security_group" {
  description = "Whether to create a security group for the node groups"
  type        = bool
  default     = true
}

variable "node_group_additional_policies" {
  description = "List of additional IAM policy ARNs to attach to the node group role"
  type        = list(string)
  default     = []
}

variable "node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type = map(object({
    ami_type                   = optional(string, "AL2_x86_64")
    capacity_type              = optional(string, "ON_DEMAND")
    desired_size               = optional(number, 1)
    disk_size                  = optional(number, 20)
    instance_types             = optional(list(string), ["t3.medium"])
    labels                     = optional(map(string), {})
    max_size                   = optional(number, 3)
    max_unavailable_percentage = optional(number, 25)
    min_size                   = optional(number, 1)
    subnet_ids                 = optional(list(string), null)
    key_name                   = optional(string, null)
    source_security_group_ids  = optional(list(string), [])
    launch_template = optional(object({
      id      = string
      version = string
    }), null)
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "cluster_addons" {
  description = "Map of cluster addon configurations to enable for the cluster"
  type = map(object({
    addon_version            = optional(string, null)
    resolve_conflicts        = optional(string, "OVERWRITE")
    service_account_role_arn = optional(string, null)
  }))
  default = {
    coredns = {
      addon_version = null
    }
    kube-proxy = {
      addon_version = null
    }
    vpc-cni = {
      addon_version = null
    }
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}
