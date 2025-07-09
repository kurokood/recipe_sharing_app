resource "aws_dynamodb_table" "recipes_table" {
  name           = "recipes"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
