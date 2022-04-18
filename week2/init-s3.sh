touch file.txt
#aws s3 rb s3://rkovalenko-first-bucket --force 
aws s3api create-bucket --bucket rkovalenko-first-bucket  --create-bucket-configuration LocationConstraint=us-west-2
aws s3api put-bucket-versioning --bucket rkovalenko-first-bucket --versioning-configuration Status=Enabled
aws s3 cp file.txt s3://rkovalenko-first-bucket
terraform import aws_s3_bucket.s3-last-bucket rkovalenko-first-bucket -lock=false
