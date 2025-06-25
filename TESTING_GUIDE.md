# 🧪 AWS Infrastructure Testing Guide

This guide will help you verify that your AWS infrastructure is working correctly after deployment.

## 📋 Prerequisites 

Before testing, ensure you have:
- ✅ Infrastructure deployed via GitHub Actions
- ✅ Your private SSH key (`~/.ssh/id_rsa`) 
- ✅ Terraform outputs (get them with `terraform output`)

## 🔍 Step 1: Get Infrastructure Information

Run these commands to get the necessary IP addresses:

```bash
# Get all outputs
terraform output

# Get specific IPs for testing
echo "Bastion/NAT IP: $(terraform output -raw bastion_nat_public_ip)"
echo "Public Web IP: $(terraform output -raw public_web_az2_ip)"
echo "Private AZ1 IP: $(terraform output -raw private_app_az1_ip)"
echo "Private AZ2 IP: $(terraform output -raw private_app_az2_ip)"
```

## 🏗️ Step 2: Test Bastion/NAT Host Access

### 2.1 SSH to Bastion Host
```bash
# Replace with your actual bastion IP
ssh -i ~/.ssh/id_rsa ec2-user@<BASTION_PUBLIC_IP>
```

**Expected Result**: ✅ Successfully connect to bastion host

### 2.2 Verify Bastion Internet Access
```bash
# From bastion host, test internet connectivity
curl -I https://google.com
ping -c 3 8.8.8.8
```

**Expected Result**: ✅ Internet access works

### 2.3 Check NAT Configuration
```bash
# Verify NAT is enabled (should return 1)
cat /proc/sys/net/ipv4/ip_forward

# Check iptables NAT rules
sudo iptables -t nat -L -n
```

**Expected Result**: ✅ IP forwarding enabled, NAT rules present

## 🌐 Step 3: Test Public Web Server

### 3.1 Direct Internet Access
```bash
# Test HTTP access from your local machine
curl http://<PUBLIC_WEB_IP>

# Or visit in browser
open http://<PUBLIC_WEB_IP>
```

**Expected Result**: ✅ See "Hello from Public Web Server - AZ-2" page

### 3.2 SSH to Public Web Server (via Bastion)
```bash
# From bastion host, SSH to public web server
ssh ec2-user@<PUBLIC_WEB_PRIVATE_IP>
```

**Expected Result**: ✅ Successfully connect

## 🔒 Step 4: Test Private Instance Access

### 4.1 SSH to Private Instances (Only via Bastion)

**Test direct access (should FAIL):**
```bash
# From your local machine - this should timeout/fail
ssh -i ~/.ssh/id_rsa ec2-user@<PRIVATE_AZ1_IP>
```

**Expected Result**: ❌ Connection should fail (timeout)

**Test via Bastion (should WORK):**
```bash
# From bastion host, SSH to private instances
ssh ec2-user@<PRIVATE_AZ1_IP>
ssh ec2-user@<PRIVATE_AZ2_IP>
```

**Expected Result**: ✅ Successfully connect to both private instances

### 4.2 Test Internet Access from Private Instances

Connect to each private instance via bastion and test:

```bash
# Test internet connectivity through NAT
curl -I https://google.com
wget -O /dev/null https://httpbin.org/ip

# Check routing (should show bastion IP as gateway)
ip route show default
```

**Expected Result**: ✅ Internet access works through bastion/NAT

## 🔗 Step 5: Test Internal VPC Communication

### 5.1 Private to Private Communication
```bash
# From private instance AZ1, ping private instance AZ2
ping -c 3 <PRIVATE_AZ2_IP>

# Test HTTP between private instances
curl http://<PRIVATE_AZ2_IP>
```

**Expected Result**: ✅ Internal communication works

### 5.2 Private to Public Communication
```bash
# From private instance, access public web server
curl http://<PUBLIC_WEB_PRIVATE_IP>
```

**Expected Result**: ✅ Communication works

## 🛡️ Step 6: Security Testing

### 6.1 Test SSH Restrictions
```bash
# Try SSH from wrong source (should fail)
# From public web server, try to SSH to private instance
ssh ec2-user@<PRIVATE_AZ1_IP>
```

**Expected Result**: ❌ Should fail (only bastion can SSH to private)

### 6.2 Test Port Restrictions
```bash
# From your local machine, try non-HTTP ports on public web
telnet <PUBLIC_WEB_IP> 3306
nc -zv <PUBLIC_WEB_IP> 22
```

**Expected Result**: ❌ Non-allowed ports should be blocked

### 6.3 Test Network ACL Rules
```bash
# Verify Network ACL associations
aws ec2 describe-network-acls --region us-east-1 --query 'NetworkAcls[?VpcId==`<VPC_ID>`]'
```

## 📊 Step 7: Performance & Health Checks

### 7.1 Check Instance Health
```bash
# Check all instances are running
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,Tags[?Key==`Name`].Value|[0],PublicIpAddress,PrivateIpAddress]' --output table
```

### 7.2 Monitor Resource Usage
```bash
# On each instance, check system resources
top
df -h
free -h
```

## 🏆 Step 8: Complete Architecture Test

### 8.1 End-to-End Workflow Test
```bash
# 1. SSH to bastion
ssh -i ~/.ssh/id_rsa ec2-user@<BASTION_PUBLIC_IP>

# 2. From bastion, SSH to private instance AZ1
ssh ec2-user@<PRIVATE_AZ1_IP>

# 3. From private AZ1, test internet via NAT
curl https://httpbin.org/ip

# 4. From private AZ1, communicate with private AZ2
ping <PRIVATE_AZ2_IP>

# 5. From private AZ1, access public web server
curl http://<PUBLIC_WEB_PRIVATE_IP>
```

**Expected Result**: ✅ All steps work seamlessly

## ✅ Success Criteria Checklist

- [ ] ✅ Bastion host accessible from internet
- [ ] ✅ Private instances accessible only via bastion
- [ ] ✅ Private instances have internet access through NAT
- [ ] ✅ Public web server accessible from internet
- [ ] ✅ All instances can communicate within VPC
- [ ] ✅ Security groups block unauthorized access
- [ ] ✅ Network ACLs provide additional security layer
- [ ] ✅ SSH access works with proper key authentication
- [ ] ✅ Web services respond correctly

## 🐛 Troubleshooting Common Issues

### Issue: SSH Connection Timeout
```bash
# Check security group rules
aws ec2 describe-security-groups --region us-east-1 --group-ids <SG_ID>

# Verify your IP is allowed
curl ifconfig.me
```

### Issue: No Internet Access from Private Instances
```bash
# Check NAT instance routing
# On bastion host:
sudo iptables -t nat -L -n
cat /proc/sys/net/ipv4/ip_forward

# Check route table
aws ec2 describe-route-tables --region us-east-1
```

### Issue: Instance Not Responding
```bash
# Check instance status
aws ec2 describe-instance-status --region us-east-1 --instance-id <INSTANCE_ID>

# Check system logs
aws ec2 get-console-output --region us-east-1 --instance-id <INSTANCE_ID>
```

## 💰 Cost Monitoring

```bash
# Check running instances
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,InstanceType,Tags[?Key==`Name`].Value|[0]]' --output table

# Remember to destroy infrastructure when testing is complete
terraform destroy
```

---

## 🎯 Quick Validation Script

Save this as `validate_infrastructure.sh`:

```bash
#!/bin/bash
set -e

echo "🔍 Validating AWS Infrastructure..."

# Get outputs
BASTION_IP=$(terraform output -raw bastion_nat_public_ip)
PUBLIC_WEB_IP=$(terraform output -raw public_web_az2_ip)

echo "🏗️ Testing public accessibility..."
curl -s -o /dev/null -w "%{http_code}" http://$PUBLIC_WEB_IP | grep -q 200 && echo "✅ Public web server accessible" || echo "❌ Public web server failed"

echo "🔐 Testing SSH to bastion..."
ssh -o ConnectTimeout=10 -o BatchMode=yes -i ~/.ssh/id_rsa ec2-user@$BASTION_IP 'echo "Connected to bastion"' && echo "✅ Bastion SSH works" || echo "❌ Bastion SSH failed"

echo "✅ Basic validation complete!"
```

Run with: `chmod +x validate_infrastructure.sh && ./validate_infrastructure.sh` 