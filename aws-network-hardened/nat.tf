resource "aws_eip" "nat" {
	domain = "vpc"
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat" {
	allocation_id = aws_eip.nat.id
	subnet_id = aws_subnet.public_main.id
}