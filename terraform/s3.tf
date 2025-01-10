terraform {
  backend "s3" {
    bucket = "cloud-resume-website-terraform-state"
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "cloud_resume_website_bucket" {
  bucket = "cloud-resume-website-bucket-terraform"
}

resource "aws_s3_bucket_ownership_controls" "cloud_resume_website_bucket_ownership" {
  bucket = aws_s3_bucket.cloud_resume_website_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "cloud_resume_website_bucket_policy" {
  bucket = aws_s3_bucket.cloud_resume_website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "AllowCloudFrontServicePrincipalReadOnly",
        Effect: "Allow",
        Principal: {
            Service: "cloudfront.amazonaws.com"
        },
        Action: "s3:GetObject",
        Resource: "${aws_s3_bucket.cloud_resume_website_bucket.arn}/*"
        Condition: {
            StringEquals: {
                "AWS:SourceArn": "${aws_cloudfront_distribution.cloud_resume_website_distribution_terraform.arn}"
              }
          }
      }
    ]
  })
}

resource "aws_s3_bucket_acl" "cloud_resume_website_bucket_acl" {
  bucket = aws_s3_bucket.cloud_resume_website_bucket.id
  acl    = "private"
}

locals {
  s3_origin_id = "cloud_resume_tf_origin"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloud_resume_website_bucket_encyrption" {
  bucket = aws_s3_bucket.cloud_resume_website_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloud_resume_website_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "cloud_resume_website_bucket_versioning" {
  bucket = aws_s3_bucket.cloud_resume_website_bucket.id
  versioning_configuration {
    status     = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "cloud_resume_website_hosting" {
  bucket = aws_s3_bucket.cloud_resume_website_bucket.id

  index_document {
    suffix = "index_tf.html"
  }
}

resource "aws_s3_bucket_logging" "cloud_resume_website_bucket_logging" {
  bucket = aws_s3_bucket.cloud_resume_website_bucket.id

  target_bucket = aws_s3_bucket.cloud_resume_website_logging_bucket.id
  target_prefix = "s3/"
}

#------------------------------------------------------------------------------------
# Logging Bucket
#------------------------------------------------------------------------------------

resource "aws_s3_bucket" "cloud_resume_website_logging_bucket" {
  bucket = "cloud-resume-website-logging-bucket-terraform"
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.cloud_resume_website_logging_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloud_resume_website_logging_bucket_encyrption" {
  bucket = aws_s3_bucket.cloud_resume_website_logging_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloud_resume_website_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "cloud_resume_website_logging_bucket_versioning" {
  bucket = aws_s3_bucket.cloud_resume_website_logging_bucket.id
  versioning_configuration {
    status     = "Enabled"
  }
}