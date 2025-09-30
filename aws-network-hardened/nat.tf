resource "aws_eip" "nat" {
	domain = "vpc"
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat" {
	allocation_id = aws_eip.nat.id
	subnet_id = aws_subnet.public_main.id
}

# Private route table + outbound rule via NAT
resource "aws_route_table" "private" {
	vpc_id = aws_vpc.main.id
	
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.nat.id
	}
}

resource "aws_route_table_association" "private_asoc" {
	subnet_id = aws_subnet.private.id
	route_table_id = aws_route_table.private.id
}