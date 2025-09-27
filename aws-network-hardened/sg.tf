# Harden default security group
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  ingress = []
  egress = []

  tags = merge(local.tags, {
    Name = "Default Security Group (do not use)"
  })
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "Security Group for ALB"
  })
}

# Security Group Rule - allow all HTTP traffic
resource "aws_security_group_rule" "http_ingress" {
  security_group_id = aws_security_group.alb_sg.id
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 80
  to_port = 80
  protocol = "tcp"
}

# Security Group rule - allow all outbound traffic
resource "aws_security_group_rule" "all_egress" {
  security_group_id = aws_security_group.alb_sg.id
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 0
  to_port = 0
  protocol = "-1"
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "Security Group for EC2"
  })
}

# Security group rule - allow HTTP traffic only from ALB
resource "aws_security_group_rule" "http_ingress_from_alb" {
  security_group_id = aws_security_group.ec2_sg.id
  type = "ingress"
  source_security_group_id = [aws_security_group.alb_sg.id]
  from_port = 80
  to_port = 80
  protocol = "tcp"
}

# Security group rule - allow all outbound traffic
resource "aws_security_group_rule" "all_egress" {
  security_group_id = aws_security_group.ec2_sg.id
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 0
  to_port = 0
  protocol = "-1"
}