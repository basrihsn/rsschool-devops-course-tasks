# We'll use the same Amazon Linux AMI for NAT instance and configure it via user_data

# Key Pair for SSH access (using variable for public key)
resource "aws_key_pair" "main" {
  key_name   = var.key_pair_name
  public_key = var.public_key

  tags = {
    Name = "${var.project_name}-${var.environment}-keypair"
  }
}

# Combined Bastion/NAT Host in AZ-1 public subnet
resource "aws_instance" "bastion_nat" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.main.key_name
  subnet_id                   = aws_subnet.public[0].id # AZ-1 public subnet
  vpc_security_group_ids      = [aws_security_group.bastion_nat.id]
  source_dest_check           = false # Important for NAT functionality
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y htop
    
    # Enable IP forwarding for NAT functionality
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -w net.ipv4.ip_forward=1
    
    # Configure iptables for NAT
    yum install -y iptables-services
    systemctl enable iptables
    systemctl start iptables
    
    # Set up NAT rules
    iptables -t nat -A POSTROUTING -o eth0 -s 10.0.0.0/16 -j MASQUERADE
    iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i eth0 -o eth0 -s 10.0.0.0/16 -j ACCEPT
    
    # Save iptables rules
    service iptables save
    
    # Create welcome message
    echo "Combined Bastion/NAT Host - AZ-1" > /etc/motd
    echo "SSH access to private instances AND NAT for private subnet internet access" >> /etc/motd
    echo "Private subnet CIDRs: ${join(", ", var.private_subnet_cidrs)}" >> /etc/motd
    echo "IP forwarding enabled and iptables NAT configured" >> /etc/motd
  EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-nat-az1"
    Type = "BastionNAT"
    AZ   = "us-east-1a"
  }
} 