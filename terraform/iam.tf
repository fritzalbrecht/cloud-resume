data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "apigateway.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_role_for_cloud_resume" {
  name               = "cloud-resume-website-terraform-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "dynamodb_item_access_policy" {
  name        = "dynamodb_item_access_policy"
  description = "Policy for access to get and update items in the cloud resume website DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
            "dynamodb:GetItem",
            "dynamodb:PutItem"
            ]
        Effect   = "Allow",
        Resource = "${aws_dynamodb_table.cloud-resume-visitor-count-table.arn}"
      }
    ]
  })
}

resource "aws_iam_policy" "kms_access_policy" {
  name        = "kms_access_policy"
  description = "Policy for KMS access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "kms:Decrypt"
        Effect   = "Allow",
        Resource = "${aws_kms_key.cloud_resume_website_key.arn}"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_access_policy" {
  name        = "lambda_access_policy"
  description = "Policy to allow APIGW to invoke lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow",
        Resource = [
          "${aws_lambda_function.get_visitors_lambda_terraform}",
          "${aws_lambda_function.post_visitors_lambda_terraform}"
        ],
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_access_policy" {
  name        = "cloudwatch_access_policy"
  description = "Policy for Cloudwatch access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents",
      ]
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynaomodb_item_policy_attachment" {
  role       = aws_iam_role.iam_role_for_cloud_resume.name
  policy_arn = aws_iam_policy.dynamodb_item_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_kms_policy_attachment" {
  role       = aws_iam_role.iam_role_for_cloud_resume.name
  policy_arn = aws_iam_policy.kms_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role   = aws_iam_role.iam_role_for_cloud_resume.name
  policy_arn = aws_iam_policy.cloudwatch_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_invoke_policy_attachment" {
  role   = aws_iam_role.iam_role_for_cloud_resume.name
  policy_arn = aws_iam_policy.lambda_access_policy.arn
}