resource "aws_s3_bucket" "backups" {
  provider = aws.p1
  bucket   = "backup-bucket"

  tags = {
    Name = "backup-bucket"
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

