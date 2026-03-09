variable "region" {
    type = string
    description = "Region to deploy the resources"
    default = "ap-southeast-1"
}

variable "tags" {
    type = map(string)
    description = "Tags to be applied to the resources"
    default = {
        Environment = "Development"
    }
}

variable "ami" {
    type = string
    description = "AMI to use for the EC2 instance"
    default = "ami-05fd46f12b86c4a6c"
}

variable "instance_type" {
    type = string
    description = "Instance type to use for the EC2 instance"
    default = "t3.micro"
}