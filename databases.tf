resource "aws_dynamodb_table" "webapp_table" {
  name           = "webapp-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "key"

  attribute {
    name = "key"
    type = "S"
  }

  tags = {
    Name = "webapp-table"
  }
}
