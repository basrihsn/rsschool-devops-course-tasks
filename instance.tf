# This file is reserved for EC2 instance configurations
# You can uncomment and modify the example below to create instances

# Public instance in AZ-2 only (us-east-1b)
resource "aws_instance" "public_web_az2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.main.key_name
  subnet_id                   = aws_subnet.public[1].id # AZ-2 public subnet
  vpc_security_group_ids      = [aws_security_group.public_web.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Public Web Server - AZ-2</h1>" > /var/www/html/index.html
    echo "<p>This server is in availability zone: us-east-1b</p>" >> /var/www/html/index.html
    echo "<p>Server can access internet and be accessed from internet</p>" >> /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-public-web-az2"
    Type = "PublicWeb"
    AZ   = "us-east-1b"
  }
}

# Private instance in AZ-1 (us-east-1a)
resource "aws_instance" "private_app_az1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = aws_subnet.private[0].id # AZ-1 private subnet
  vpc_security_group_ids = [aws_security_group.private.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Private App Server - AZ-1</h1>" > /var/www/html/index.html
    echo "<p>This server is in availability zone: us-east-1a</p>" >> /var/www/html/index.html
    echo "<p>Server can access internet through bastion/NAT host</p>" >> /var/www/html/index.html
    echo "<p>Server can only be accessed via bastion host</p>" >> /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-private-app-az1"
    Type = "PrivateApp"
    AZ   = "us-east-1a"
  }

  depends_on = [aws_route.private_nat]
}

# Private instance in AZ-2 (us-east-1b)
resource "aws_instance" "private_app_az2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = aws_subnet.private[1].id # AZ-2 private subnet
  vpc_security_group_ids = [aws_security_group.private.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Private App Server - AZ-2</h1>" > /var/www/html/index.html
    echo "<p>This server is in availability zone: us-east-1b</p>" >> /var/www/html/index.html
    echo "<p>Server can access internet through bastion/NAT host in AZ-1</p>" >> /var/www/html/index.html
    echo "<p>Server can only be accessed via bastion host</p>" >> /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-private-app-az2"
    Type = "PrivateApp"
    AZ   = "us-east-1b"
  }

  depends_on = [aws_route.private_nat]
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