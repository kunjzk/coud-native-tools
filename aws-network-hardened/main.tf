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