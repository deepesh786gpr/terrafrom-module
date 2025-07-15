# EC2 Module Outputs

output "instance_ids" {
  description = "List of IDs of instances"
  value       = aws_instance.main[*].id
}

output "instance_arns" {
  description = "List of ARNs of instances"
  value       = aws_instance.main[*].arn
}

output "instance_public_ips" {
  description = "List of public IP addresses assigned to the instances"
  value       = aws_instance.main[*].public_ip
}

output "instance_private_ips" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.main[*].private_ip
}

output "instance_public_dns" {
  description = "List of public DNS names assigned to the instances"
  value       = aws_instance.main[*].public_dns
}

output "instance_private_dns" {
  description = "List of private DNS names assigned to the instances"
  value       = aws_instance.main[*].private_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.main[0].id, "")
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = try(aws_security_group.main[0].arn, "")
}

output "key_pair_name" {
  description = "The key pair name"
  value       = try(aws_key_pair.main[0].key_name, "")
}

output "key_pair_fingerprint" {
  description = "The MD5 public key fingerprint"
  value       = try(aws_key_pair.main[0].fingerprint, "")
}

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.ec2_role[0].name, "")
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.ec2_role[0].arn, "")
}

output "iam_instance_profile_name" {
  description = "The instance profile's name"
  value       = try(aws_iam_instance_profile.ec2_profile[0].name, "")
}

output "iam_instance_profile_arn" {
  description = "The ARN assigned by AWS to the instance profile"
  value       = try(aws_iam_instance_profile.ec2_profile[0].arn, "")
}

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = try(aws_launch_template.main[0].id, "")
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = try(aws_launch_template.main[0].arn, "")
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = try(aws_launch_template.main[0].latest_version, "")
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = try(aws_autoscaling_group.main[0].id, "")
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = try(aws_autoscaling_group.main[0].name, "")
}

output "autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = try(aws_autoscaling_group.main[0].arn, "")
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = try(aws_autoscaling_group.main[0].min_size, "")
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = try(aws_autoscaling_group.main[0].max_size, "")
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = try(aws_autoscaling_group.main[0].desired_capacity, "")
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = try(aws_autoscaling_group.main[0].default_cooldown, "")
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = try(aws_autoscaling_group.main[0].health_check_grace_period, "")
}

output "autoscaling_group_health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  value       = try(aws_autoscaling_group.main[0].health_check_type, "")
}

output "autoscaling_group_availability_zones" {
  description = "The availability zones of the autoscale group"
  value       = try(aws_autoscaling_group.main[0].availability_zones, [])
}

output "autoscaling_group_vpc_zone_identifier" {
  description = "The VPC zone identifier"
  value       = try(aws_autoscaling_group.main[0].vpc_zone_identifier, [])
}
