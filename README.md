# RSSchool DevOps Course Task 1

## Overview

This project demonstrates Infrastructure as Code (IaC) practices using Terraform to set up AWS infrastructure with automated CI/CD pipelines via GitHub Actions. It establishes secure authentication between GitHub Actions and AWS using OpenID Connect (OIDC) instead of long-lived access keys.

## Architecture

The project sets up the following AWS infrastructure:

- **IAM OIDC Provider**: Enables GitHub Actions to authenticate with AWS using short-lived tokens
- **IAM Role**: `GithubActionsRole` with necessary permissions for infrastructure management
- **S3 Backend**: Remote state storage with DynamoDB locking for Terraform state management

## Features

- ✅ Secure GitHub Actions ↔ AWS authentication using OIDC
- ✅ Automated Terraform workflows (format, plan, apply)
- ✅ Remote state management with S3 + DynamoDB locking
- ✅ Comprehensive IAM permissions for AWS resource management
- ✅ Branch-based deployment strategy

## Prerequisites

Before using this project, ensure you have:

1. **AWS Account** with appropriate permissions
2. **GitHub Repository** with Actions enabled
3. **Pre-existing AWS Resources**:
   - S3 bucket: `mystates-terraform-state`
   - DynamoDB table: `mystates-terraform-state-lock`
4. **Local Development** (optional):
   - Terraform >= 1.6.6
   - AWS CLI configured

## Quick Start

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd rsschool-devops-course-tasks
```

### 2. Configure Variables
Update `terraform.tfvars` with your specific values:
```hcl
aws_region = "us-east-1"  # Your preferred AWS region
iam_policy_names = [
    "AmazonEC2FullAccess",
    "AmazonRoute53FullAccess",
    # ... other required policies
]
```

### 3. Deploy Infrastructure
Push to the `main` branch to trigger the GitHub Actions workflow, or run locally:
```bash
terraform init
terraform plan
terraform apply
```

## Project Structure

```
├── .github/workflows/
│   └── terraform.yml           # GitHub Actions workflow for CI/CD
├── .gitignore                  # Git ignore patterns for Terraform files
├── githubActions_iam_role.tf   # IAM OIDC provider and role configuration
├── main.tf                     # Terraform providers and backend configuration
├── terraform.tfvars           # Variable values (AWS region, IAM policies)
├── variables.tf               # Variable definitions
└── README.md                  # Project documentation
```

## File Descriptions

### `main.tf`
- Configures AWS provider (version 6.0.0)
- Sets up S3 backend for remote state storage
- Defines DynamoDB table for state locking

### `githubActions_iam_role.tf`
- Creates IAM OIDC provider for GitHub Actions authentication
- Defines IAM role with appropriate trust policy
- Attaches AWS managed policies for resource access

### `terraform.tfvars`
- Specifies AWS region (`us-east-1`)
- Lists required IAM policies for comprehensive AWS access
- Includes policies for EC2, S3, IAM, VPC, Route53, SQS, EventBridge, and DynamoDB

### `variables.tf`
- Defines input variables for AWS region and IAM policy names
- Provides type validation and descriptions

### `.github/workflows/terraform.yml`
- **Trigger**: Push/PR to `main` branch
- **Jobs**:
  1. `terraform-check`: Format validation
  2. `terraform-plan`: Infrastructure planning
  3. `terraform-apply`: Infrastructure deployment
- **Security**: Uses OIDC for AWS authentication

## GitHub Actions Workflow

The automated pipeline consists of three sequential jobs:

1. **Format Check** (`terraform-check`)
   - Validates Terraform code formatting
   - Runs on every push/PR

2. **Plan** (`terraform-plan`)
   - Initializes Terraform
   - Validates configuration
   - Generates execution plan
   - Requires format check to pass

3. **Apply** (`terraform-apply`)
   - Deploys infrastructure changes
   - Only runs on `main` branch pushes
   - Requires plan to complete successfully

## Security Considerations

- **OIDC Authentication**: No long-lived AWS credentials stored in GitHub
- **Least Privilege**: IAM role scoped to specific repository
- **State Encryption**: Terraform state encrypted in S3
- **State Locking**: DynamoDB prevents concurrent modifications

## IAM Permissions

The GitHub Actions role includes these AWS managed policies:
- `AmazonEC2FullAccess` - EC2 instance management
- `AmazonRoute53FullAccess` - DNS management
- `AmazonS3FullAccess` - Object storage access
- `IAMFullAccess` - Identity and access management
- `AmazonVPCFullAccess` - Network infrastructure
- `AmazonSQSFullAccess` - Message queuing
- `AmazonEventBridgeFullAccess` - Event routing
- `AmazonDynamoDBFullAccess_v2` - NoSQL database access

## Repository Configuration

Ensure your GitHub repository has the following configuration:
- Repository name: `basrihsn/rsschool-devops-course-tasks`
- Actions enabled
- Appropriate branch protection rules for `main`

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify OIDC provider thumbprint is current
   - Check repository name in trust policy
   - Ensure AWS account ID is correct

2. **State Lock Errors**
   - Verify DynamoDB table exists and is accessible
   - Check AWS permissions for DynamoDB operations

3. **Workflow Failures**
   - Review GitHub Actions logs
   - Verify Terraform version compatibility
   - Check AWS resource quotas

## Contributing

1. Create feature branch from `main`
2. Make changes and test locally
3. Submit pull request for review
4. Merge to `main` triggers deployment

## License

This project is part of the RSSchool DevOps course curriculum.

---

**Note**: This is a learning project for DevOps practices. Review and adapt security settings for production use.