locals {
    tags = merge(var.tags, {
        Module = "Network Basic with modules"
    })
}

data "aws_secretsmanager_secret" "db_password" {
    name = "prod/ec2/dbpassword"
}

provider "aws" {
  region = var.region
}

module "network" {
    source = "./modules/network"
    tags = local.tags
    vpc_cidr = "10.0.0.0/16"
}

module "security_group" {
    source = "git::https://github.com/kunjzk/coud-native-tools.git//aws-security-group-basic?ref=main"
    tags = local.tags
    vpc_id = module.network.vpc_id

}

resource "aws_iam_role" "ec2_secrets_role" {
    name = "ec2-secrets-manager-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })
    tags = local.tags
}

resource "aws_iam_role_policy" "ec2_read_db_secret" {
    name = "ec2-read-db-secret"
    role = aws_iam_role.ec2_secrets_role.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect   = "Allow"
            Action   = "secretsmanager:GetSecretValue"
            Resource = data.aws_secretsmanager_secret.db_password.arn
        }]
    })
}

resource "aws_iam_instance_profile" "ec2_secrets_profile" {
    name = "ec2-secrets-manager-profile"
    role = aws_iam_role.ec2_secrets_role.name
    tags = local.tags
}

module "ec2" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "6.3.0"
    ami           = var.ec2_instance.ami
    name = "demo_instance"
    create_eip = true
    instance_type = var.ec2_instance.instance_type
    key_name      = "For SSH"
    monitoring    = true
    subnet_id     = module.network.subnet_id
    vpc_security_group_ids = [module.security_group.security_group_id]
    iam_instance_profile   = aws_iam_instance_profile.ec2_secrets_profile.name
    tags = merge(local.tags, {
        Module = "EC2"
    })
    user_data = <<EOF
#!/bin/bash
SECRET_ARN=${data.aws_secretsmanager_secret.db_password.arn}
echo "DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id $SECRET_ARN --query SecretString --output text)" >> /etc/app.env
EOF
}