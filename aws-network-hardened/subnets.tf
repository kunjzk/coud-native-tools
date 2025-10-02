
# Subnet
resource "aws_subnet" "public_main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  tags = merge(local.tags, {
    Name = "Subnet Public Main"
  })
}

# Subnet
resource "aws_subnet" "public_second" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
  tags = merge(local.tags, {
    Name = "Subnet Public Second"
  })
}

# Private subnet
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-southeast-1a"
  tags = merge(local.tags, {
    Name = "Private Subnet"
  })
}