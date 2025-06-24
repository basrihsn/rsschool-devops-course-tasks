aws_region = "us-east-1"

# List of AWS managed IAM policy names to attach to the GitHub Actions role
iam_policy_names = [
  "AmazonEC2FullAccess",
  "AmazonRoute53FullAccess",
  "AmazonS3FullAccess",
  "IAMFullAccess",
  "AmazonVPCFullAccess",
  "AmazonSQSFullAccess",
  "AmazonEventBridgeFullAccess",
  "AmazonDynamoDBFullAccess_v2"
]

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

availability_zones = ["us-east-1a", "us-east-1b"]

project_name = "rsschool-task2"
environment  = "test"

# SSH Key Configuration
key_pair_name = "rsschool-key"
# public_key will be provided via GitHub Secret or environment variable
# public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDY..."  
# my_ip will be provided via GitHub Secret for better security
# my_ip         = "0.0.0.0/0"  # This allows access from anywhere (less secure)

# Instance Configuration (AWS Free Tier eligible)
instance_type = "t2.micro" 