resource "aws_cloudwatch_log_group" "cloud_resume_website_visitor_count_rest_api_cloudwatch_group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id}/${aws_api_gateway_stage.cloud_resume_website_visitor_count_rest_api_stage.stage_name}"
  retention_in_days = 7
  kms_key_id = aws_kms_key.cloud_resume_website_key.arn
}