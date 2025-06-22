terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" 
      version = "6.0.0" # The version of the AWS provider
    }
  }

  backend "s3" {
    bucket         = "mystates-terraform-state" # The name of the S3 bucket
    key            = "state/terraform.tfstate" # The key for the S3 bucket
    region         = "us-east-1" # The region for the S3 bucket
    dynamodb_table = "mystates-terraform-state-lock" # DynamoDB table for state locking
    encrypt        = true # Encrypt the state file
  }
}

provider "aws" {
  region = var.aws_region
}