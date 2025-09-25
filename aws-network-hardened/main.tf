locals {
    tags = {
        Environment = "Development"
        Project = "Network Hardened"
    }
}

# What we need:
# 1. VPC (remove rules from default security group)
# 2. Subnet
# 3. Internet Gateway
# 4. Route Table
# 5. Route
# 6. Route Table Association
# 7. Security Group & rules
# 8. Elastic IP for EC2 Instance
# 9. Tiny EC2 Instance
# 10. SSM setup for EC2 instance - policy, role, instance profile, association

provider "aws" {
  region = "ap-southeast-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = merge(local.tags, {
    Name = "VPC Main"
  })
}

# Harden default security group
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  ingress = []
  egress = []

  tags = merge(local.tags, {
    Name = "Default Security Group (do not use)"
  })
}

# Subnet
resource "aws_subnet" "public_main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  tags = merge(local.tags, {
    Name = "Subnet Public Main"
  })
}

# IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "Internet Gateway Main"
  })
}

# Route Table
resource "aws_route_table" "public_main" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "Route Table Public Main"
  })
}

# Route
resource "aws_route" "public_main" {
  route_table_id = aws_route_table.public_main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

# Route Table Association
resource "aws_route_table_association" "public_main" {
  subnet_id = aws_subnet.public_main.id
  route_table_id = aws_route_table.public_main.id
}

# Security Group
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "Security Group Main"
  })
}

# Security Group Rule - allow all HTTP traffic
resource "aws_security_group_rule" "https_ingress" {
  security_group_id = aws_security_group.main.id
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 80
  to_port = 80
  protocol = "tcp"
}

# Security Group rule - allow all outbound traffic
resource "aws_security_group_rule" "all_egress" {
  security_group_id = aws_security_group.main.id
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 0
  to_port = 0
  protocol = "-1"
}

# Trust policy: EC2 can assume this role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Role for the instance
resource "aws_iam_role" "ec2_ssm_role" {
  name               = "ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

# Attach AWS-managed policy: AmazonSSMManagedInstanceCore
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Instance profile (binds role → EC2)
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# Tiny EC2 Instance
resource "aws_instance" "main" {
  ami           = "ami-05fd46f12b86c4a6c"  # Amazon Linux 2023 for ap-southeast-1
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
  tags = merge(local.tags, {
    Name = "Tiny EC2 Instance Main"
  })
}

# Elastic IP
resource "aws_eip" "main" {
  domain = "vpc"
  tags = merge(local.tags, {
    Name = "Elastic IP Main"
  })
}

# Attach Elastic IP to EC2 Instance
resource "aws_eip_association" "main" {
  instance_id = aws_instance.main.id
  allocation_id = aws_eip.main.id
}

# Remove all rules from default NACL - stops prowler from complaining
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  # No ingress or egress blocks here = everything denied
  # (default NACL rule = *deny all* if no explicit allow)
  
  tags = merge(local.tags, {
    Name = "Default NACL (DO NOT USE, deny all traffic)"
  }) 
}


# Custom NACL
resource "aws_network_acl" "web_nacl" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, {
    Name = "Web NACL"
  })
}

## INGRESS rules (into subnet)
# Allow HTTP
resource "aws_network_acl_rule" "in_http" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow HTTPS
resource "aws_network_acl_rule" "in_https" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Block inbound RDP (explicilty deny RDP traffic)
resource "aws_network_acl_rule" "in_rdp" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3389
  to_port        = 3389
}


# Allow inbound ephemeral (responses to outbound connections)
resource "aws_network_acl_rule" "in_ephemeral" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}


## EGRESS rules (out of subnet)
# Allow HTTPS out
resource "aws_network_acl_rule" "out_https" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow HTTP out (optional; keep if your instances need it)
resource "aws_network_acl_rule" "out_http" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 210
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow outbound ephemeral (responses to inbound 80/443)
resource "aws_network_acl_rule" "out_ephemeral" {
  network_acl_id = aws_network_acl.web_nacl.id
  rule_number    = 220
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

## Associate NACL to the subnet (replaces default)
resource "aws_network_acl_association" "web_nacl_assoc" {
  subnet_id      = aws_subnet.public_main.id
  network_acl_id = aws_network_acl.web_nacl.id
}

# Output the Elastic IP for SSH access
output "elastic_ip" {
  description = "Elastic IP of EC2 instance"
  value       = aws_eip.main.public_ip
}

# Output instance ID for SSM access
output "instance_id" {
  description = "Instance ID of EC2 instance"
  value       = aws_instance.main.id
}