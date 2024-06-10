resource "aws_kms_key" "cloud_resume_website_key" {
  description             = "This key is used to encrypt and decrypt cloud resume website bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true 
}

resource "aws_kms_key_policy" "cloud_resume_website_key_policy" {
  key_id = aws_kms_key.cloud_resume_website_key.id
  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "Enable root permissions"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${var.aws_account_id}:root"
          },
          Action   = "kms:*"
          Resource = "*"
        },
        {
          Sid    = "Enable lambda permissions"
          Effect = "Allow"
          Principal = {
            AWS = "${aws_iam_role.iam_role_for_cloud_resume.arn}"
          },
          Action   = "kms:Decrypt"
          Resource = "*"
        },
        {
          Sid    = "Allow CloudFront to use the key to deliver logs",
          Effect = "Allow",
          Principal = {
              Service = "delivery.logs.amazonaws.com"
          },
          Action   = "kms:GenerateDataKey*",
          Resource = "*"
        },
        {
          Sid = "Allow Cloudfront use of the key",
          Effect = "Allow",
          Principal = {
              Service = [
                  "cloudfront.amazonaws.com"
              ]
          },
          Action = [
              "kms:Decrypt",
              "kms:Encrypt",
              "kms:GenerateDataKey*"
            ],
          Resource = "*",
          Condition = {
              StringEquals = {
                  "aws:SourceArn": "${aws_cloudfront_distribution.cloud_resume_website_distribution_terraform.arn}"
            }
          }
        },
        {
          Sid = "Allow Cloudwatch use of the key",
          Effect = "Allow",
          Principal = {
              Service = [
                  "logs.us-east-1.amazonaws.com"
              ]
          },
          Action = [
              "kms:Decrypt",
              "kms:Encrypt",
              "kms:GenerateDataKey*"
            ],
          Resource = "*",
          Condition = {
              ArnLike = {
                  "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:us-east-1:${var.aws_account_id}:*"
            }
          }
        }
      ]
    }
  )
}