terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

module "groups" {
  source = "./modules/groups"
  vpc_id = module.network.vpc_id
}

module "network" {
  source = "./modules/network"
}

module "db" {
  source = "./modules/db"
  aws_db_subnet_group = module.network.rds-group-subnets
  aws_security_group_id = module.groups.aws_sg_private_id
}

module "lb" {
  source = "./modules/lb"
  vpc_id = module.network.vpc_id
  aws_target_subnets_ids = module.network.lb-group-subnets
  aws_security_group_id = module.groups.aws_sg_public_id
  autoscaling_group_id = aws_autoscaling_group.asg.id
}
module "sns_sqs" {
  source = "./modules/sns_sqs"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "instance_private_1" {
  subnet_id     =  module.network.private_subnet_1_id
  ami           = "ami-00ee4df451840fa9d"
  key_name      = "aws"
  instance_type = "t2.micro"
  security_groups = [module.groups.aws_sg_private_id]

tags = {
  "Name" = "ec2-private-subnet"
} 
  user_data = filebase64("user_data.sh")
 }

resource "aws_instance" "instance_public_nat" {
  subnet_id     = module.network.public_subnet_1_id
  ami           = "ami-0032ea5ae08aa27a2"
  key_name      = "aws"
  instance_type = "t2.micro"
  source_dest_check = false   

  tags =  {
    "Name" = "public-nat-bastion"
  } 
}

resource "aws_route" "route-nat-to" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = module.network.private_route_table_id
  instance_id = aws_instance.instance_public_nat.id
}

resource "aws_network_interface_sg_attachment" "sg_attachment_aws_net" {
  security_group_id    = module.groups.aws_sg_public_id
  network_interface_id = aws_instance.instance_public_nat.primary_network_interface_id
}

resource "aws_launch_template" "asg_template" {
  image_id      = "ami-00ee4df451840fa9d"
  instance_type = "t2.micro"
  key_name = "aws"
  name = "final-asg-template"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [module.groups.aws_sg_public_id]
  }

  user_data =  filebase64("user_data.sh")
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = [module.network.public_subnet_1_id, module.network.public_subnet_2_id]
  desired_capacity   = 2
  max_size           = 2
  min_size           = 1
  name = "asg"

  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }

  tags = [ {
    "name" = "asg"
  } ]
}