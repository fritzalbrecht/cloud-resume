data "archive_file" "postVisitors-lambda" {
  type        = "zip"
  source_file = "${path.module}/bin/postVisitors/lambda_function.py"
  output_path = "${path.module}/bin/postVisitors/postVisitors_function_payload.zip"
}

data "archive_file" "getVisitors-lambda" {
  type        = "zip"
  source_file = "${path.module}/bin/getVisitors/lambda_function.py"
  output_path = "${path.module}/bin/getVisitors/getVisitors_function_payload.zip"
}

resource "aws_lambda_function" "post_visitors_lambda_terraform" {
  filename      = "${path.module}/bin/postVisitors/postVisitors_function_payload.zip"
  function_name = "cloud-resume-terraform-post-visitors"
  role          = aws_iam_role.iam_role_for_cloud_resume.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 10
  runtime       = "python3.9"
}

resource "aws_lambda_function" "get_visitors_lambda_terraform" {
  filename      = "${path.module}/bin/getVisitors/getVisitors_function_payload.zip"
  function_name = "cloud-resume-terraform-get-visitors"
  role          = aws_iam_role.iam_role_for_cloud_resume.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 10
  runtime       = "python3.9"
}

resource "aws_lambda_permission" "post_visitors_api_gw" {
  statement_id  = "allow_api_gw_invoke_lambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_visitors_lambda_terraform.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "get_visitors_api_gw" {
  statement_id  = "allow_api_gw_invoke_get_lambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_visitors_lambda_terraform.function_name
  principal     = "apigateway.amazonaws.com"
}
