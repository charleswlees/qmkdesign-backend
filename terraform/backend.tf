terraform {
  backend "s3" {
    bucket = "qmkdesign-backend-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
