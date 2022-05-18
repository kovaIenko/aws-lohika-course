
variable "aws_target_subnets_ids" {
  type = list(string)
}


# variable "aws_target_id_1" {
#   type = string
# }

# variable "aws_target_id_2" {
#   type = string
# }

variable "aws_security_group_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "autoscaling_group_id" {
  type = string
}