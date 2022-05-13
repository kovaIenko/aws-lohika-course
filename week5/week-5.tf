terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}


resource "aws_sqs_queue" "terraform" {
  name                        = "queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  policy = jsonencode({
   "Version": "2012-10-17",
   "Id": "Queue1_Policy_UUID",
   "Statement": [{
      "Sid":"Queue1_AllActions",
      "Effect": "Allow",
      "Principal": "*"
      "Action": [
         "sqs:SendMessage",
         "sqs:ReceiveMessage"
      ], 
      "Resource": "arn:aws:sqs:us-west-2:567168357526:queue.fifo"
   }]
})
}


resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
}


resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = "ruskov004@gmail.com"
}


resource "aws_instance" "instance" {
  ami           = "ami-00ee4df451840fa9d"
  key_name      = "aws"
  instance_type = "t2.micro"  
}

resource "aws_network_interface_sg_attachment" "sg_attachment_aws_net" {
  security_group_id    = aws_security_group.public.id
  network_interface_id = aws_instance.instance.primary_network_interface_id
}

resource "aws_security_group" "public" {
  name = "public-sg"
}

resource "aws_security_group_rule" "public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
 
output "queue_type" {
  value = aws_sqs_queue.terraform.url
} 