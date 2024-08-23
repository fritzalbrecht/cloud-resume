resource "aws_cloudwatch_log_group" "cloud_resume_website_visitor_count_rest_api_cloudwatch_group" {
  name              = "/aws/apigateway/"
  retention_in_days = 7
  kms_key_id = aws_kms_key.cloud_resume_website_key.arn
}