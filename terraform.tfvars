# The AWS region to deploy the resources to
aws_region = "us-east-1"

# List of AWS managed IAM policy names to attach to the GitHub Actions role
iam_policy_names = [
    "AmazonEC2FullAccess",
    "AmazonRoute53FullAccess",
    "AmazonS3FullAccess",
    "IAMFullAccess",
    "AmazonVPCFullAccess",
    "AmazonSQSFullAccess",
    "AmazonEventBridgeFullAccess"
]