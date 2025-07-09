resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "recipe-sharing-app-121485"

  tags = {
    Name = "Frontend Bucket"
  }
}

resource "random_id" "stack_id" {
  byte_length = 8
}
