resource "aws_api_gateway_account" "cloud_resume_website_visitor_count_rest_api_cloudwatch_account" {
  cloudwatch_role_arn = aws_iam_role.iam_role_for_cloud_resume.arn
}

resource "aws_api_gateway_rest_api" "cloud_resume_website_visitor_count_rest_api" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "cloud_resume_website_visitor_count_rest_api"
      version = "1.0"
    }
    paths = {
      "/path1" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = "${aws_lambda_function.get_visitors_lambda_terraform.invoke_arn}"
          }
        }
      },
      "/path2" = {
        post = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = "${aws_lambda_function.post_visitors_lambda_terraform.invoke_arn}"
          }
        }
      }
    }
  })

  name = "cloud_resume_website_visitor_count_rest_api"
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

resource "aws_api_gateway_domain_name" "api_gateway_domain_name" {
  certificate_arn = "${var.acm_cert_arn}"
  domain_name     = "api.fritzalbrecht.com"
}

resource "aws_api_gateway_base_path_mapping" "cloud_resume_website_visitor_count_api_get_mapping" {
  api_id      = aws_api_gateway_rest_api.cloud_resume_website_visitor_count_rest_api.id
  stage_name  = aws_api_gateway_stage.cloud_resume_website_visitor_count_rest_api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api_gateway_domain_name.domain_name
}