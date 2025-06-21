terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }

  backend "s3" {
    bucket         = "mystates-terraform-state"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mystates-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}