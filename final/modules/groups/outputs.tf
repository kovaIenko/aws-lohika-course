

# output "auto_scaling_group" {
#   value = aws_autoscaling_group.asg.id
# }

output "aws_sg_public_id" {
   value = aws_security_group.public.id
}

output "aws_sg_private_id" {
   value = aws_security_group.private.id
}
