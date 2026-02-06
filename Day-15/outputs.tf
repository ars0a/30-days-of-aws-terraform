
# Outputs for day-15-demo VPC Peering

output "primary_vpc_id" {
  value = aws_vpc.primary_vpc.id
}

output "secondary_vpc_id" {
  value = aws_vpc.secondary_vpc.id
}

output "primary_vpc_cidr" {
  value = aws_vpc.primary_vpc.cidr_block
}

output "secondary_vpc_cidr" {
  value = aws_vpc.secondary_vpc.cidr_block
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.primary_to_secondary.id
}

output "vpc_peering_status" {
  value = aws_vpc_peering_connection.primary_to_secondary.accept_status
}

output "primary_instance_id" {
  value = aws_instance.primary_instance.id
}

output "secondary_instance_id" {
  value = aws_instance.secondary_instance.id
}

output "primary_instance_private_ip" {
  value = aws_instance.primary_instance.private_ip
}

output "secondary_instance_private_ip" {
  value = aws_instance.secondary_instance.private_ip
}

output "primary_instance_public_ip" {
  value = aws_instance.primary_instance.public_ip
}

output "secondary_instance_public_ip" {
  value = aws_instance.secondary_instance.public_ip
}

output "test_connectivity_command" {
  value = <<-EOT
    To test VPC peering connectivity:
    1. SSH into Primary instance: ssh -i your-key.pem ubuntu@${aws_instance.primary_instance.public_ip}
    2. Ping Secondary instance: ping ${aws_instance.secondary_instance.private_ip}

    Or reverse:
    1. SSH into Secondary: ssh -i your-key.pem ubuntu@${aws_instance.secondary_instance.public_ip}
    2. Ping Primary: ping ${aws_instance.primary_instance.private_ip}
  EOT
}
