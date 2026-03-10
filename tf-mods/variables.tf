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

variable "ec2_instance" {
    type = object({
        ami = string
        instance_type = string
    })
    description = "EC2 instance configuration"
    default = {
        ami = "ami-05fd46f12b86c4a6c"
        instance_type = "t3.micro"
    }
}

variable "db_password" {
    type = string
    description = "Password for the database"
    sensitive = true
    default = "password123"
}