variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "iam_policy_names" {
  description = "List of AWS managed IAM policy names to attach to the GitHub Actions role"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "task_2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances"
  type        = string
  default     = "rsschool-task-2-key"
}

variable "public_key" {
  description = "Public key content for SSH access (paste your ~/.ssh/id_rsa.pub content here)"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address for SSH access (CIDR format, e.g., 1.2.3.4/32)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (t2.micro is AWS Free Tier eligible)"
  type        = string
  default     = "t2.micro"
} 