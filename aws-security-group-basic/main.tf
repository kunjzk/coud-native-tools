locals {
    tags = merge(var.tags, {
        Module = "Security Group"
    })
}

# Security Group
resource "aws_security_group" "main" {
  vpc_id = var.vpc_id
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