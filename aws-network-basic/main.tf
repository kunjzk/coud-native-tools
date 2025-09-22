locals {
    tags = {
        Environment = "Development"
        Project = "Network Basic"
    }
}

# What we need:
# 1. VPC
# 2. Subnet
# 3. Internet Gateway
# 4. Route Table
# 5. Route
# 6. Route Table Association
# 7. Security Group & rules
# 8. Elastic IP for EC2 Instance
# 9. Tiny EC2 Instance

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

# Security Group Rule - allow all SSH traffic
resource "aws_security_group_rule" "ssh_ingress" {
  security_group_id = aws_security_group.main.id
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 22
  to_port = 22
  protocol = "tcp"
}

# Security Group Rule - allow all HTTPS traffic
resource "aws_security_group_rule" "https_ingress" {
  security_group_id = aws_security_group.main.id
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 443
  to_port = 443
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

# Elastic IP
resource "aws_eip" "main" {
  domain = "vpc"
  tags = merge(local.tags, {
    Name = "Elastic IP Main"
  })
}

# Tiny EC2 Instance
resource "aws_instance" "main" {
  ami           = "ami-05fd46f12b86c4a6c"  # Amazon Linux 2023 for ap-southeast-1
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name = "For SSH"  # Key pair name from EC2 console
  tags = merge(local.tags, {
    Name = "Tiny EC2 Instance Main"
  })
}

# Attach Elastic IP to EC2 Instance
resource "aws_eip_association" "main" {
  instance_id = aws_instance.main.id
  allocation_id = aws_eip.main.id
}

# Output the Elastic IP for SSH access
output "elastic_ip" {
  description = "Elastic IP address for SSH access to EC2 instance"
  value       = aws_eip.main.public_ip
}

output "ssh_command" {
  description = "Command to SSH into the EC2 instance"
  value       = "ssh -i ~/.ssh/aws-priv-key.pem ec2-user@${aws_eip.main.public_ip}"
}