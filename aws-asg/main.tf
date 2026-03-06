locals {
  tags = {
    Environment = "Development"
    Project = "ASG"
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = merge(local.tags, {
    Name = "VPC Main"
  })
}



