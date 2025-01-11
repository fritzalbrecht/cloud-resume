resource "aws_api_gateway_account" "cloud_resume_website_visitor_count_rest_api_cloudwatch_account" {
  cloudwatch_role_arn = aws_iam_role.iam_role_for_cloud_resume.arn
}

resource "aws_api_gateway_rest_api" "cloud_resume_website_visitor_count_rest_api" {
  name        = "cloud-resume-website-terraform-visitor-count-api-tf"
  description = "API for cloud resume website visitor count created with terraform"
}

resource "aws_api_gateway_resource" "get_visitors_resource" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  parent_id   = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.root_resource_id
  path_part    = "get-visitors-tf"
}

resource "aws_api_gateway_resource" "post_visitors_resource" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  parent_id   = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.root_resource_id
  path_part    = "post-visitors-tf"
}

resource "aws_api_gateway_method" "get_visitors_post" {
  rest_api_id   = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id   = aws_api_gateway_resource.get_visitors_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "get_visitors_post_integration" {
  rest_api_id          = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id          = aws_api_gateway_resource.get_visitors_resource.id
  http_method          = aws_api_gateway_method.get_visitors_post.http_method
  type                 = "AWS_PROXY"
  integration_http_method = "POST"
  uri                  = "${aws_lambda_function.get_visitors_lambda_terraform.invoke_arn}"
}

resource "aws_api_gateway_method_response" "get_visitors_post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id = aws_api_gateway_resource.get_visitors_resource.id
  http_method = aws_api_gateway_method.get_visitors_post.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "get_visitors_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id = aws_api_gateway_resource.get_visitors_resource.id
  http_method = aws_api_gateway_method.get_visitors_post.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
  }
  
  response_templates = {
    "application/json" = "{}"
  }
}

resource "aws_api_gateway_method" "post_visitors_post" {
  rest_api_id   = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id   = aws_api_gateway_resource.post_visitors_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "post_visitors_post_integration" {
  rest_api_id          = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id          = aws_api_gateway_resource.post_visitors_resource.id
  http_method          = aws_api_gateway_method.post_visitors_post.http_method
  type                 = "AWS_PROXY"
  integration_http_method = "POST"
  uri                  = "${aws_lambda_function.post_visitors_lambda_terraform.invoke_arn}"
}

resource "aws_api_gateway_method_response" "post_visitors_post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id = aws_api_gateway_resource.post_visitors_resource.id
  http_method = aws_api_gateway_method.post_visitors_post.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "post_visitors_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id = aws_api_gateway_resource.post_visitors_resource.id
  http_method = aws_api_gateway_method.post_visitors_post.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
  }
  
  response_templates = {
    "application/json" = "{}"
  }
}

module "get_cors" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  api_resource_id = aws_api_gateway_resource.get_visitors_resource.id
}

module "postcors" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  api_resource_id = aws_api_gateway_resource.post_visitors_resource.id
}