
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