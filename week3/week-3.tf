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

resource "aws_dynamodb_table" "items" {
  name             = "items"
  hash_key         = "ID"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

attribute {
    name = "ID"
    type = "N"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage = 10
  engine = "postgres"
  instance_class = "db.t3.micro"
  name = "terraform"
  username = "postgres"
  vpc_security_group_ids = [aws_security_group.public.id]
  password =  "postgres"
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_port" {
  value = aws_db_instance.postgres.port
}

variable "vpcId" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = string
  default     = "vpc-05c9b537de7cb434a"
}

resource "aws_s3_bucket" "s3-last-bucket" {
  # bucket = "rkovalenko-first-bucket-temp"
  # force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "some_bucket_access" {
  bucket = aws_s3_bucket.s3-last-bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_iam_policy" "bucket_policy" {
  name        = "s3-policy"
  description = "Allow"
  policy = jsonencode({          
    "Version" : "2012-10-17",
     "Statement" : [
    {
      "Sid" : "VisualEditor0",
      "Effect" : "Allow",
      "Action" : [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource" : [
        "arn:aws:s3:::*/*",
        "arn:aws:s3:::rkovalenko-second-bucket"
      ]
    }]})
}

resource "aws_iam_policy" "dynamodb_policy" {
  name = "dynamodb-policy"
  description = "Allow"
  policy = jsonencode({  
    "Version": "2012-10-17",
    "Statement":[{
      "Effect": "Allow",
      "Action": [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem",
      "dynamodb:List*",
      "dynamodb:DescribeReservedCapacity*",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive"
      ],
      "Resource": "*"
     }]
  })
}

resource "aws_iam_role" "some_role" {
  name = "my_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "some_dynamodb_policy" {
  role       = aws_iam_role.some_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "some_bucket_policy" {
  role       = aws_iam_role.some_role.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}

resource "aws_iam_instance_profile" "default_rkovalenko" {
  name = "default_rkovalenko"
  role = aws_iam_role.some_role.name
}

resource "aws_instance" "my-ec2" {
  ami = "ami-00ee4df451840fa9d"
  instance_type = "t2.micro"
  key_name = "aws"
  iam_instance_profile = aws_iam_instance_profile.default_rkovalenko.id

  provisioner "local-exec" {
      
    command = <<EOT
      "aws s3 cp s3://rkovalenko-second-bucket/create-table-items.json create-table-items.json"
      "aws s3 cp s3://rkovalenko-second-bucket/dynamodb-script.sh dynamodb-script.sh"
      "aws s3 cp s3://rkovalenko-second-bucket/rds-script.sql rds-script.sql"
    EOT
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.public.id
  network_interface_id = aws_instance.my-ec2.primary_network_interface_id
}

resource "aws_security_group" "public" {
  name = "cloudcasts-public-sg"
  description = "Public internet access"
  vpc_id = var.vpcId 
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
 
resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
 
resource "aws_security_group_rule" "public_in_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

output "instance_ip_addr" {
  value = aws_instance.my-ec2.public_ip
}