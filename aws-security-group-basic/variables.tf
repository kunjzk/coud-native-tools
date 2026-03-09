variable "tags" {
    type = map(string)
    description = "Tags to be applied to the resources"
    default = {}
}

variable "vpc_id" {
    type = string
    description = "ID of the VPC"
    validation {
        condition = length(var.vpc_id) > 0
        error_message = "VPC ID must be provided"
    }
}