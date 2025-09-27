# Harden default security group
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  ingress = []
  egress = []

  tags = merge(local.tags, {
    Name = "Default Security Group (do not use)"
  })
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