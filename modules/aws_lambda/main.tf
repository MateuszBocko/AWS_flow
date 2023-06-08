provider "aws" {
  region = "eu-central-1"
}

# create IAM role
resource "aws_iam_role" "lambda_role" {
name   = "Test_Lambda_Function_Role"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# create IAM policy
resource "aws_iam_policy" "iam_policy_for_lambda" {

 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   },
   {
     "Action": [
       "s3:GetObject"
     ],
     "Resource": "arn:aws:s3:::*",
     "Effect": "Allow"
    }
 ]
}
EOF
}

# attach IAM policies to role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

# zip python code
data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/python/"
output_path = "${path.module}/python/hello-python.zip"
}

# create lambda function
resource "aws_lambda_function" "terraform_lambda_func" {
filename                       = "${path.module}/python/hello-python.zip"
function_name                  = "Test_Lambda_Function"
role                           = aws_iam_role.lambda_role.arn
handler                        = "index.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
environment {
 variables = {
  DB_endpoint = var.DB_endpoint
  username = var.username
  password = var.password
   }
  }
}
#
## Adding S3 bucket as trigger to my lambda and giving the permissions
#resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
#  bucket = aws_s3_bucket.bucket.id
#  lambda_function {
#    lambda_function_arn = aws_lambda_function.test_lambda.arn
#    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
#
#  }
#}
#resource "aws_lambda_permission" "test" {
#  statement_id  = "AllowS3Invoke"
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.test_lambda.function_name
#  principal     = "s3.amazonaws.com"
#  source_arn    = "arn:aws:s3:::${aws_s3_bucket.bucket.id}"
#}