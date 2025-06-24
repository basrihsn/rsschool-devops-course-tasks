# This file is reserved for EC2 instance configurations
# You can uncomment and modify the example below to create instances

# Example EC2 instances in public subnets
resource "aws_instance" "public_instance" {
  count = length(aws_subnet.public)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_default_security_group.default.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Public Instance ${count.index + 1}</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-public-instance-${count.index + 1}"
    Type = "Public"
  }
}

#Example EC2 instances in private subnets
resource "aws_instance" "private_instance" {
  count = length(aws_subnet.private)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_default_security_group.default.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-instance-${count.index + 1}"
    Type = "Private"
  }
}

# Data source for Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
} 