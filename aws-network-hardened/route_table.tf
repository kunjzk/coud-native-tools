
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

# Route Table Association to first subnet
resource "aws_route_table_association" "public_main" {
  subnet_id = aws_subnet.public_main.id
  route_table_id = aws_route_table.public_main.id
}

# Route Table Association to second subnet
resource "aws_route_table_association" "public_second" {
  subnet_id = aws_subnet.public_second.id
  route_table_id = aws_route_table.public_main.id
}

# Route table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "Route Table Private"
  })
}

# Route for private subnet
resource "aws_route" "private_subnet_internet_traffic_to_nat" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

# Route table association for private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private_route_table.id
}