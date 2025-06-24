# RSSchool DevOps Course Task 2

## AWS VPC Infrastructure with Terraform

This project contains Terraform configuration to create a robust AWS VPC infrastructure with public and private subnets across multiple Availability Zones.

## Architecture

The infrastructure includes:
- **VPC**: A Virtual Private Cloud with DNS support
- **Public Subnets**: 2 subnets in different AZs with internet access
- **Private Subnets**: 2 subnets in different AZs without direct internet access
- **Internet Gateway**: Provides internet access for public subnets
- **Route Tables**: Proper routing configuration for public and private subnets
- **Security Group**: Default security group allowing internal communication

## File Structure

```
├── main.tf              # Provider configuration and Terraform settings
├── variables.tf         # Variable definitions
├── terraform.tfvars     # Variable values
├── network.tf           # VPC, subnets, IGW, and routing configuration
├── instance.tf          # Placeholder for EC2 instance configurations
├── outputs.tf           # Output values
└── README.md           # This file
```

## Network Configuration

### Routing Rules
- **Public Subnets**: Can reach the internet via Internet Gateway (0.0.0.0/0 → IGW)
- **Private Subnets**: Can communicate within VPC, no direct internet access
- **Internal Communication**: All subnets can reach each other within the VPC

### Default Configuration
- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
- **Private Subnets**: 10.0.10.0/24, 10.0.20.0/24
- **Availability Zones**: us-west-2a, us-west-2b
- **Region**: us-west-2

## Usage

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed

### Deployment Steps

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Review the plan**
   ```bash
   terraform plan
   ```

3. **Apply the configuration**
   ```bash
   terraform apply
   ```

4. **Destroy resources (when needed)**
   ```bash
   terraform destroy
   ```

### Customization

You can customize the infrastructure by modifying `terraform.tfvars`:

```hcl
aws_region = "us-east-1"
vpc_cidr   = "172.16.0.0/16"

public_subnet_cidrs  = ["172.16.1.0/24", "172.16.2.0/24"]
private_subnet_cidrs = ["172.16.10.0/24", "172.16.20.0/24"]

availability_zones = ["us-east-1a", "us-east-1b"]

project_name = "my-project"
environment  = "production"
```

## Outputs

After successful deployment, Terraform will output:
- VPC ID and CIDR block
- Public and private subnet IDs
- Internet Gateway ID
- Route table IDs
- Default security group ID

## Security Considerations

- Private subnets have no direct internet access
- Default security group allows internal VPC communication
- Public subnets have auto-assign public IP enabled
- All resources are tagged for easy identification

## Next Steps

- Uncomment and configure EC2 instances in `instance.tf` if needed
- Add NAT Gateway for private subnet internet access (if required)
- Configure additional security groups for specific use cases
- Set up Application Load Balancer for high availability