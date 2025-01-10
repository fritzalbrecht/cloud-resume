resource "aws_dynamodb_table_item" "visitor-count-terraform" {
  table_name = aws_dynamodb_table.cloud-resume-visitor-count-table.name
  hash_key   = aws_dynamodb_table.cloud-resume-visitor-count-table.hash_key

  item = <<ITEM
{
  "ID": {"S": "Visitors-terraform-website"},
  "Count": {"N": "0"}
}
ITEM

lifecycle {
    ignore_changes = [
      item
    ]
  }
}

resource "aws_dynamodb_table_item" "visitor-count-cdk" {
  table_name = aws_dynamodb_table.cloud-resume-visitor-count-table.name
  hash_key   = aws_dynamodb_table.cloud-resume-visitor-count-table.hash_key

  item = <<ITEM
{
  "ID": {"S": "Visitors-cdk-website"},
  "Count": {"N": "0"}
}
ITEM

lifecycle {
    ignore_changes = [
      item
    ]
  }
}

resource "aws_dynamodb_table" "cloud-resume-visitor-count-table" {
  name           = "cloud-resume-website-visitor-count"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
    kms_key_arn = aws_kms_key.cloud_resume_website_key.arn
  }
}