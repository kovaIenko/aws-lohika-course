
resource "aws_sqs_queue" "sqs-queue" {
  name                        = "edu-lohika-training-aws-sqs-queue"
  fifo_queue                  = false
  #content_based_deduplication = true
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
      "Resource": "arn:aws:sqs:us-west-2:567168357526:edu-lohika-training-aws-sqs-queue"
   }]
})
}


resource "aws_sns_topic" "edu-lohika-training-aws-sns-topic" {
  name = "edu-lohika-training-aws-sns-topic"
}


resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.edu-lohika-training-aws-sns-topic.arn
  protocol  = "email"
  endpoint  = "ruskov004@gmail.com"
}
