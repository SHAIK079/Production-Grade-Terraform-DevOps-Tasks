output "vpc_id" {
  value = aws_vpc.three_tier.id
}
output "public_subnet_1_id" {
  value = aws_subnet.pub1.id
}
output "public_subnet_2_id" {
  value = aws_subnet.pub2.id
}
output "private_db_subnets" {
    value = [aws_subnet.prvt7.id, aws_subnet.prvt8.id]
    }


output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "bastion_sg_id" {
  description = "ID of the Bastion Host SG"
  value       = aws_security_group.bastion.id
}

output "database_sg_id" {
  description = "ID of the Database SG"
  value       = aws_security_group.database.id
}
