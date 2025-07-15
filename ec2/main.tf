# EC2 Module - Production Ready
# Creates EC2 instances with security groups, key pairs, and optional load balancer

# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnet" "selected" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

# Key Pair
resource "aws_key_pair" "main" {
  count = var.create_key_pair ? 1 : 0

  key_name   = var.key_name
  public_key = var.public_key

  tags = merge(var.tags, {
    Name = var.key_name
    Type = "Key Pair"
  })
}

# Security Group
resource "aws_security_group" "main" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.name}-"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.name} EC2 instances"

  # SSH access
  dynamic "ingress" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
      description = "SSH access"
    }
  }

  # HTTP access
  dynamic "ingress" {
    for_each = var.enable_http_access ? [1] : []
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.http_cidr_blocks
      description = "HTTP access"
    }
  }

  # HTTPS access
  dynamic "ingress" {
    for_each = var.enable_https_access ? [1] : []
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.https_cidr_blocks
      description = "HTTPS access"
    }
  }

  # Custom ingress rules
  dynamic "ingress" {
    for_each = var.custom_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
    Type = "Security Group"
  })
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-ec2-role"
    Type = "IAM Role"
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.name}-ec2-profile"
  role = aws_iam_role.ec2_role[0].name

  tags = merge(var.tags, {
    Name = "${var.name}-ec2-profile"
    Type = "IAM Instance Profile"
  })
}

# Attach policies to IAM role
resource "aws_iam_role_policy_attachment" "ec2_policies" {
  count = var.create_iam_role ? length(var.iam_policy_arns) : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = var.iam_policy_arns[count.index]
}

# Launch Template
resource "aws_launch_template" "main" {
  count = var.use_launch_template ? 1 : 0

  name_prefix   = "${var.name}-"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.create_key_pair ? aws_key_pair.main[0].key_name : var.key_name

  vpc_security_group_ids = var.create_security_group ? [aws_security_group.main[0].id] : var.security_group_ids

  iam_instance_profile {
    name = var.create_iam_role ? aws_iam_instance_profile.ec2_profile[0].name : var.iam_instance_profile_name
  }

  user_data = base64encode(var.user_data)

  dynamic "block_device_mappings" {
    for_each = var.ebs_block_devices
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
        iops                  = block_device_mappings.value.iops
        throughput            = block_device_mappings.value.throughput
        encrypted             = block_device_mappings.value.encrypted
        delete_on_termination = block_device_mappings.value.delete_on_termination
      }
    }
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = var.name
      Type = "EC2 Instance"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.name}-volume"
      Type = "EBS Volume"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.name}-launch-template"
    Type = "Launch Template"
  })
}

# EC2 Instances
resource "aws_instance" "main" {
  count = var.use_launch_template ? 0 : var.instance_count

  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.create_key_pair ? aws_key_pair.main[0].key_name : var.key_name

  subnet_id                   = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids      = var.create_security_group ? [aws_security_group.main[0].id] : var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address

  iam_instance_profile = var.create_iam_role ? aws_iam_instance_profile.ec2_profile[0].name : var.iam_instance_profile_name

  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  monitoring = var.enable_detailed_monitoring

  dynamic "root_block_device" {
    for_each = var.root_block_device != null ? [var.root_block_device] : []
    content {
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
      iops                  = root_block_device.value.iops
      throughput            = root_block_device.value.throughput
      encrypted             = root_block_device.value.encrypted
      delete_on_termination = root_block_device.value.delete_on_termination
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
      iops                  = ebs_block_device.value.iops
      throughput            = ebs_block_device.value.throughput
      encrypted             = ebs_block_device.value.encrypted
      delete_on_termination = ebs_block_device.value.delete_on_termination
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-${count.index + 1}"
    Type = "EC2 Instance"
  })

  volume_tags = merge(var.tags, {
    Name = "${var.name}-${count.index + 1}-volume"
    Type = "EBS Volume"
  })
}

# Auto Scaling Group (if using launch template)
resource "aws_autoscaling_group" "main" {
  count = var.use_launch_template && var.create_asg ? 1 : 0

  name                = "${var.name}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main[0].id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      Name = "${var.name}-asg"
      Type = "Auto Scaling Group"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
