output "ec2_public_ip" {
    description = "Public IP of the EC2 instance"
    value = module.ec2.public_ip
}

output "ssh_command" {
    description = "Command to SSH into the EC2 instance"
    value = "ssh -i ~/.ssh/aws-priv-key.pem ec2-user@${module.ec2.public_ip}"
}