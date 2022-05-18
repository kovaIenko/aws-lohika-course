

output "public_subnet_1_id" {
  description = "public subnet #1"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "public subnet #2"
  value       = aws_subnet.public_2.id
}


output "private_subnet_2_id" {
  description = "private subnet #2"
  value       = aws_subnet.private_2.id
}

output "private_subnet_1_id" {
  description = "private subnet #1"
  value       = aws_subnet.private_1.id
}

output "rds-group-subnets" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "lb-group-subnets" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}
