provider "aws" {
    region = "ap-southeast-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "demo" {
  bucket        = "terraform-demo-${random_id.suffix.hex}"
  force_destroy = true
}

output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}