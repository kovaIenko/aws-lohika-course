


resource "aws_dynamodb_table" "edu-lohika-training-aws-dynamodb" {
  name             = "edu-lohika-training-aws-dynamodb"
  hash_key         = "UserName"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

attribute {
    name = "UserName"
    type = "S"
  }
}


resource "aws_s3_bucket" "s3-bucket" {
  bucket = "rkovalenko-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "some_bucket_access" {
  bucket = aws_s3_bucket.s3-bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_iam_policy" "bucket_policy" {
  name        = "s3-my-policy"
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
        "arn:aws:s3:::rkovalenko-bucket"
      ]
    }]})
}


resource "aws_iam_policy" "dynamodb_policy" {
  name = "dynamodb-policy-final-task"
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
  name = "my_iam_final-task_role"

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


resource "aws_db_instance" "postgres" {
  allocated_storage = 10
  engine = "postgres"
  instance_class = "db.t3.micro"
  name = "EduLohikaTrainingAwsRds"
  db_name = "duLohikaTrainingAwsRds"
  username = "rootuser"
  vpc_security_group_ids = [var.aws_security_group_id]
  password =  "rootuser"
  db_subnet_group_name = aws_db_subnet_group.default.name
}

resource "aws_db_subnet_group" "default" {
  name        = "rds-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = var.aws_db_subnet_group
}