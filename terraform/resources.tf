resource "aws_s3_bucket" "qmkdesign-backend-backup-bucket" {
  provider = aws.p1
  bucket   = "qmkdesign-backend-backup-bucket"

  tags = {
    Name = "qmkdesign-backend-backup-bucket"
  }
}

resource "aws_dynamodb_table" "user-data" {
  provider     = aws.p1
  name         = "user-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }
}

resource "aws_ecr_repository" "qmkdesign-backend" {
  provider = aws.p1
  name = "qmkdesign-backend"
}

resource "aws_ecr_lifecycle_policy" "cleanup" {
  provider   = aws.p1
  repository = aws_ecr_repository.qmkdesign-backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Only keep 2 images in ECR"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 2
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_lambda_function" "backend_lambda" {
  provider      = aws.p1
  function_name = "backend_api"
  role          = aws_iam_role.lambda_role.arn  
  
  package_type = "Image"
  image_uri    = "${aws_ecr_repository.qmkdesign-backend.repository_url}:latest"  
  
  timeout     = 30
  memory_size = 128
  
  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.user-data.name
      S3_BUCKET      = aws_s3_bucket.qmkdesign-backend-backup-bucket.id
    }
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy.lambda_policy
  ]
}


resource "aws_lambda_function_url" "api_url" {
  provider           = aws.p1
  function_name      = aws_lambda_function.backend_lambda.function_name
  authorization_type = "NONE"  
}

output "function_url" {
  value = aws_lambda_function_url.api_url.function_url
}
