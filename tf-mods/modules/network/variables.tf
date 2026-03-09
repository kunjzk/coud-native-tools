variable "tags" {
    type = map(string)
    description = "Tags to be applied to the resources"
    default = {}
}

variable "vpc_cidr" {
    type = string
    description = "CIDR block for the VPC"
    validation {
        condition = length(var.vpc_cidr) > 0
        error_message = "VPC CIDR block must be provided"
    }
}