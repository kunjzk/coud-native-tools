# if using count
# output "ec2_public_ips" {
#     description = "Public IP of each EC2 instance"
#     value = { for i, ip in module.ec2[*].public_ip : "instance_${i}" => ip }
# }

# output "ssh_commands" {
#     description = "SSH command for each EC2 instance"
#     value = { for i, ip in module.ec2[*].public_ip : "instance_${i}" => "ssh -i ~/.ssh/aws-priv-key.pem ec2-user@${ip}" }
# }

# if using for_each
output "ec2_public_ips" {
    description = "Public IP of each EC2 instance"
    value = { for name, instance in module.ec2 : name => instance.public_ip }
}
output "ssh_commands" {
    description = "SSH command for each EC2 instance"
    value = { for name, instance in module.ec2 : name => "ssh -i ~/.ssh/aws-priv-key.pem ec2-user@${instance.public_ip}" }
}