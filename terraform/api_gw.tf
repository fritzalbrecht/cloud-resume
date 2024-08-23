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
  api_key_required = true
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
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
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
  api_key_required = true
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
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
  }
  
  response_templates = {
    "application/json" = "{}"
  }
}

resource "aws_api_gateway_method" "get_visitors_options" {
  rest_api_id   = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id   = aws_api_gateway_resource.get_visitors_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_visitors_options_integration" {
  rest_api_id          = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id          = aws_api_gateway_resource.get_visitors_resource.id
  http_method          = aws_api_gateway_method.get_visitors_options.http_method
  type                 = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "get_visitors_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id = aws_api_gateway_resource.get_visitors_resource.id
  http_method = aws_api_gateway_method.get_visitors_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "get_visitors_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id = aws_api_gateway_resource.get_visitors_resource.id
  http_method = aws_api_gateway_method.get_visitors_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
  }
  
  response_templates = {
    "application/json" = "{}"
  }
}

resource "aws_api_gateway_method" "post_visitors_options" {
  rest_api_id   = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id   = aws_api_gateway_resource.post_visitors_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_visitors_options_integration" {
  rest_api_id          = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id          = aws_api_gateway_resource.post_visitors_resource.id
  http_method          = aws_api_gateway_method.post_visitors_options.http_method
  type                 = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "post_visitors_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id = aws_api_gateway_resource.post_visitors_resource.id
  http_method = aws_api_gateway_method.post_visitors_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "post_visitors_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  resource_id = aws_api_gateway_resource.post_visitors_resource.id
  http_method = aws_api_gateway_method.post_visitors_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
  }
  
  response_templates = {
    "application/json" = "{}"
  }
}

resource "aws_api_gateway_deployment" "cloud_resume_website_visitor_count_rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "cloud_resume_website_visitor_count_rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.cloud_resume_website_visitor_count_rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  stage_name    = "prod"
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  stage_name  = aws_api_gateway_stage.cloud_resume_website_visitor_count_rest_api_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}

resource "aws_api_gateway_domain_name" "fritzalbrecht" {
  domain_name              = "api.fritzalbrecht.com"
  certificate_arn = "arn:aws:acm:us-east-1:144131464452:certificate/3ab5a465-0533-4fdf-bfc6-57c4f5259e3b"

  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_base_path_mapping" "fritzalbrecht_base_mapping" {
  api_id      = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  stage_name  = aws_api_gateway_stage.cloud_resume_website_visitor_count_rest_api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.fritzalbrecht.domain_name
}

resource "aws_api_gateway_api_key" "cloud_resume_website_api_key_tf" {
  name   = "cloud-resume-website-api-key-tf"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "cloud_resume_website_api_key_usage_plan_tf" {
  name = "cloud-resume-website-api-key-usage-plan-tf"
  
  api_stages {
    api_id = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
    stage  = aws_api_gateway_stage.cloud_resume_website_visitor_count_rest_api_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "cloud_resume_website_api_key_usage_plan_key_tf" {
  key_id        = aws_api_gateway_api_key.cloud_resume_website_api_key_tf.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.cloud_resume_website_api_key_usage_plan_tf.id
}
