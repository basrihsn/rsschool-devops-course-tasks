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

vpc_cidr   = "10.0.0.0/16"

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

availability_zones = ["us-east-1a", "us-east-1b"]

project_name = "rsschool-devops"
environment  = "dev" 