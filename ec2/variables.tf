# EC2 Module Variables

variable "name" {
  description = "Name to be used on EC2 instance created"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 1
}

variable "ami_id" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
  default     = ""
}

variable "create_key_pair" {
  description = "Whether to create a key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "The public key material for the key pair"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs to launch in"
  type        = list(string)
}

variable "create_security_group" {
  description = "Whether to create security group"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = false
}

variable "enable_ssh_access" {
  description = "Whether to enable SSH access"
  type        = bool
  default     = true
}

variable "ssh_cidr_blocks" {
  description = "List of CIDR blocks for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_http_access" {
  description = "Whether to enable HTTP access"
  type        = bool
  default     = false
}

variable "http_cidr_blocks" {
  description = "List of CIDR blocks for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_https_access" {
  description = "Whether to enable HTTPS access"
  type        = bool
  default     = false
}

variable "https_cidr_blocks" {
  description = "List of CIDR blocks for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "custom_ingress_rules" {
  description = "List of custom ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = ""
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data will trigger a destroy and recreate when set to true"
  type        = bool
  default     = false
}

variable "enable_detailed_monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "create_iam_role" {
  description = "Whether to create an IAM role for the instance"
  type        = bool
  default     = false
}

variable "iam_instance_profile_name" {
  description = "The IAM Instance Profile to launch the instance with"
  type        = string
  default     = ""
}

variable "iam_policy_arns" {
  description = "List of IAM policy ARNs to attach to the IAM role"
  type        = list(string)
  default     = []
}

variable "root_block_device" {
  description = "Configuration block to customize details about the root block device of the instance"
  type = object({
    volume_size           = number
    volume_type           = string
    iops                  = number
    throughput            = number
    encrypted             = bool
    delete_on_termination = bool
  })
  default = null
}

variable "ebs_block_devices" {
  description = "Additional EBS block devices to attach to the instance"
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = string
    iops                  = number
    throughput            = number
    encrypted             = bool
    delete_on_termination = bool
  }))
  default = []
}

variable "use_launch_template" {
  description = "Whether to use launch template instead of direct instance creation"
  type        = bool
  default     = false
}

variable "create_asg" {
  description = "Whether to create Auto Scaling Group"
  type        = bool
  default     = false
}

variable "min_size" {
  description = "The minimum size of the auto scale group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum size of the auto scale group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = number
  default     = 1
}

variable "target_group_arns" {
  description = "A set of aws_alb_target_group ARNs, for use with Application or Network Load Balancing"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = 300
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}
