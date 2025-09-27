
# Trust policy: EC2 can assume this role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Role for the instance
resource "aws_iam_role" "ec2_ssm_role" {
  name               = "ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

# Attach AWS-managed policy: AmazonSSMManagedInstanceCore
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Instance profile (binds role → EC2)
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# Tiny EC2 Instance
resource "aws_instance" "main" {
  ami           = "ami-05fd46f12b86c4a6c"  # Amazon Linux 2023 for ap-southeast-1
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_main.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
  tags = merge(local.tags, {
    Name = "Tiny EC2 Instance Main"
  })
}

# Elastic IP
resource "aws_eip" "main" {
  domain = "vpc"
  tags = merge(local.tags, {
    Name = "Elastic IP Main"
  })
}

# Attach Elastic IP to EC2 Instance
resource "aws_eip_association" "main" {
  instance_id = aws_instance.main.id
  allocation_id = aws_eip.main.id
}
