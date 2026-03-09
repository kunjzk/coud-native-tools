locals {
    tags = merge(var.tags, {
        Module = "Network Basic with modules"
    })
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

module "ec2" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "6.3.0"
    ami           = var.ami
    name = "demo_instance"
    create_eip = true
    instance_type = var.instance_type
    key_name      = "For SSH"
    monitoring    = true
    subnet_id     = module.network.subnet_id
    vpc_security_group_ids = [module.security_group.security_group_id]
    tags = merge(local.tags, {
        Module = "EC2"
    })
}