# S3
terraform import aws_s3_bucket.qmkdesign-backend-backup-bucket qmkdesign-backend-backup-bucket

# DynamoDB 
terraform import aws_dynamodb_table.user-data user-data

# ECR
terraform import aws_ecr_repository.qmkdesign-backend qmkdesign-backend
terraform import aws_ecr_lifecycle_policy.cleanup qmkdesign-backend

# Lambda 
terraform import aws_lambda_function.backend_lambda backend_api
terraform import aws_lambda_function_url.api_url backend_api

# IAM 
terraform import aws_iam_role.lambda_role backend_api_lambda_role
terraform import aws_iam_role_policy_attachment.lambda_basic backend_api_lambda_role/arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
terraform import aws_iam_role_policy.lambda_policy backend_api_lambda_role:lambda_policy

