# Security Group for Combined Bastion/NAT Host
resource "aws_security_group" "bastion_nat" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-nat-"
  vpc_id      = aws_vpc.main.id

  # SSH access from your IP (for bastion functionality)
  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # HTTP traffic from private subnets (for NAT functionality)
  ingress {
    description = "HTTP from private subnets"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  # HTTPS traffic from private subnets (for NAT functionality)
  ingress {
    description = "HTTPS from private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  # All traffic from private subnets (for internal VPC communication)
  ingress {
    description = "All traffic from private subnets"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-nat-sg"
    Type = "BastionNAT"
  }
}

# Security Group for Public Web Servers
resource "aws_security_group" "public_web" {
  name_prefix = "${var.project_name}-${var.environment}-public-web-"
  vpc_id      = aws_vpc.main.id

  # HTTP access from internet
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from internet
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from bastion/NAT
  ingress {
    description     = "SSH from bastion/NAT"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_nat.id]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-web-sg"
    Type = "PublicWeb"
  }
}

# Security Group for Private Instances
resource "aws_security_group" "private" {
  name_prefix = "${var.project_name}-${var.environment}-private-"
  vpc_id      = aws_vpc.main.id

  # SSH from bastion/NAT
  ingress {
    description     = "SSH from bastion/NAT"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_nat.id]
  }

  # HTTP from public web servers
  ingress {
    description     = "HTTP from public web"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_web.id]
  }

  # Communication within private subnet
  ingress {
    description = "All traffic from private subnets"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  # Communication from VPC (allows internal VPC traffic)
  ingress {
    description = "All traffic from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # All outbound traffic (through bastion/NAT)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-sg"
    Type = "Private"
  }
} 