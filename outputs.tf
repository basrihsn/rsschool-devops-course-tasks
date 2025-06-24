output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "default_security_group_id" {
  description = "ID of the default security group"
  value       = aws_default_security_group.default.id
}

output "availability_zones" {
  description = "Availability zones used"
  value       = var.availability_zones
}

# Security Group outputs
output "bastion_nat_security_group_id" {
  description = "ID of the combined bastion/NAT security group"
  value       = aws_security_group.bastion_nat.id
}

output "public_web_security_group_id" {
  description = "ID of the public web security group"
  value       = aws_security_group.public_web.id
}

output "private_security_group_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private.id
}

# Network ACL outputs
output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = aws_network_acl.public.id
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = aws_network_acl.private.id
}

# Instance outputs
output "bastion_nat_public_ip" {
  description = "Public IP of the combined bastion/NAT host"
  value       = aws_instance.bastion_nat.public_ip
}

output "bastion_nat_private_ip" {
  description = "Private IP of the combined bastion/NAT host"
  value       = aws_instance.bastion_nat.private_ip
}

output "public_web_az2_ip" {
  description = "Public IP of web server in AZ-2"
  value       = aws_instance.public_web_az2.public_ip
}

output "private_app_az1_ip" {
  description = "Private IP of application server in AZ-1"
  value       = aws_instance.private_app_az1.private_ip
}

output "private_app_az2_ip" {
  description = "Private IP of application server in AZ-2"
  value       = aws_instance.private_app_az2.private_ip
}

# Key pair output
output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.main.key_name
}

# Connection information
output "ssh_to_bastion_nat" {
  description = "SSH command to connect to bastion/NAT host"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.bastion_nat.public_ip}"
}

output "ssh_to_private_az1_via_bastion" {
  description = "SSH command to connect to AZ-1 private instance via bastion"
  value       = "ssh -i ~/.ssh/id_rsa -o ProxyCommand='ssh -i ~/.ssh/id_rsa -W %h:%p ec2-user@${aws_instance.bastion_nat.public_ip}' ec2-user@${aws_instance.private_app_az1.private_ip}"
}

output "ssh_to_private_az2_via_bastion" {
  description = "SSH command to connect to AZ-2 private instance via bastion"
  value       = "ssh -i ~/.ssh/id_rsa -o ProxyCommand='ssh -i ~/.ssh/id_rsa -W %h:%p ec2-user@${aws_instance.bastion_nat.public_ip}' ec2-user@${aws_instance.private_app_az2.private_ip}"
} 