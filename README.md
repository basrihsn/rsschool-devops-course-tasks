# RSSchool DevOps Course Task 2

## AWS VPC Infrastructure with Terraform

This project contains Terraform configuration to create a robust AWS VPC infrastructure with public and private subnets across multiple availability zones.

## Architecture

The infrastructure includes:
- **VPC**: A Virtual Private Cloud with DNS support
- **Public Subnets**: 2 subnets in different AZs with internet access
- **Private Subnets**: 2 subnets in different AZs without direct internet access
- **Internet Gateway**: Provides internet access for public subnets
- **NAT Instance**: Cost-effective NAT solution for private subnet internet access
- **Bastion Host**: Secure entry point for accessing private subnet instances
- **Route Tables**: Proper routing configuration for public and private subnets
- **Security Groups**: Layer 4 firewall rules for different instance types
- **EC2 Instances**: Web servers in public subnets, application servers in private subnets

## File Structure

```
├── main.tf              # Provider configuration and Terraform settings
├── variables.tf         # Variable definitions
├── terraform.tfvars     # Variable values
├── network.tf           # VPC, subnets, IGW, and routing configuration
├── network-acls.tf     # Network ACL definitions for additional security
├── security-groups.tf   # Security group definitions
├── bastion.tf          # Bastion host and NAT instance configuration
├── instance.tf         # EC2 instance configurations (web and app servers)
├── outputs.tf          # Output values
├── .github/
│   └── workflows/
│       └── terraform.yml # GitHub Actions CI/CD pipeline
└── README.md           # This file
```

## Network Configuration

### Routing Rules
- **Public Subnets**: Can reach the internet via Internet Gateway (0.0.0.0/0 → IGW)
- **Private Subnets**: Can reach internet via NAT Instance (0.0.0.0/0 → NAT Instance)
- **Internal Communication**: All subnets can reach each other within the VPC

### Security Groups & Network ACLs
- **Bastion Security Group**: SSH access from your IP only
- **NAT Security Group**: HTTP/HTTPS from private subnets, SSH from bastion
- **Public Web Security Group**: HTTP/HTTPS from internet, SSH from bastion
- **Private Security Group**: SSH from bastion, HTTP from public web servers
- **Public Network ACL**: Subnet-level security for public subnets
- **Private Network ACL**: Subnet-level security for private subnets

### Instance Types
- **Bastion Host**: Secure jump server in public subnet for accessing private instances
- **NAT Instance**: Cost-effective NAT solution in public subnet for private internet access
- **Public Web Servers**: Web servers in public subnets accessible from internet
- **Private App Servers**: Application servers in private subnets accessible via bastion

### Default Configuration
- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
- **Private Subnets**: 10.0.10.0/24, 10.0.20.0/24
- **Availability Zones**: us-east-1a, us-east-1b
- **Region**: us-east-1
- **Instance Type**: t3.micro
- **Key Pair**: rsschool-key

## Usage

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- SSH key pair generated (`ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa`)
- S3 bucket and DynamoDB table for Terraform state (as configured in main.tf)

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
- Security group IDs for all components
- Public and private IP addresses of all instances
- SSH commands for connecting to bastion and private instances

## Security Considerations

- **Defense in Depth**: Multiple layers of security with security groups and NACLs
- **Bastion Host**: Single point of entry for private subnet access
- **NAT Instance**: Private instances can reach internet without being directly accessible
- **Security Groups**: Principle of least privilege applied to all instance types
- **SSH Key Authentication**: Key-based authentication for all instances
- **Network Segmentation**: Public and private subnets isolated appropriately

## How to Access Instances

### Access Bastion Host
```bash
ssh -i ~/.ssh/id_rsa ec2-user@<bastion-public-ip>
```

### Access Private Instances via Bastion (SSH Jump)
```bash
# Method 1: Using ProxyCommand
ssh -i ~/.ssh/id_rsa -o ProxyCommand='ssh -i ~/.ssh/id_rsa -W %h:%p ec2-user@<bastion-public-ip>' ec2-user@<private-instance-ip>

# Method 2: SSH Agent Forwarding
ssh -A -i ~/.ssh/id_rsa ec2-user@<bastion-public-ip>
# Then from bastion:
ssh ec2-user@<private-instance-ip>
```

### Test Web Servers
```bash
# Public web servers
curl http://<public-web-server-ip>

# Private app servers (from bastion)
curl http://<private-app-server-ip>
```

## Cost Optimization

This architecture uses a **NAT Instance** instead of a **NAT Gateway** for cost optimization:
- **NAT Instance**: ~$8-10/month (t3.micro instance cost)
- **NAT Gateway**: ~$45/month (plus data transfer costs)

The NAT instance provides the same functionality at a much lower cost, making it ideal for development and testing environments.

## Next Steps

- Implement monitoring and logging with CloudWatch
- Add Application Load Balancer for high availability
- Configure auto-scaling for web servers
- Implement automated backups and disaster recovery
- Add SSL/TLS certificates for HTTPS
- Configure AWS Systems Manager for patch management

## Troubleshooting

### Common Issues
1. **SSH Key Issues**: Ensure your public key exists at `~/.ssh/id_rsa.pub`
2. **Security Group Access**: Update `my_ip` variable with your actual IP address
3. **NAT Instance**: Ensure source/destination check is disabled
4. **Route Tables**: Verify private route table points to NAT instance

### Validation Commands
```bash
# Check if NAT instance can route traffic
# From a private instance:
curl -I http://www.google.com

# Check security group rules
aws ec2 describe-security-groups --group-ids <security-group-id>

# Check route tables
aws ec2 describe-route-tables --route-table-ids <route-table-id>
```