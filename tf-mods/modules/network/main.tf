locals {
    tags = merge(var.tags, {
        Module = "Network"
    })
}
# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
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