resource "aws_cloudfront_distribution" "cloud_resume_website_distribution_terraform" {
    origin {
        domain_name = "${aws_s3_bucket.cloud_resume_website_bucket.bucket_regional_domain_name}"
        origin_id   = local.s3_origin_id
        origin_access_control_id = aws_cloudfront_origin_access_control.cloud_resume_oac.id
    }

    enabled             = true
    is_ipv6_enabled     = true
    default_root_object = "index_tf.html"
    aliases = ["tf.fritzalbrecht.com"]

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = local.s3_origin_id

        forwarded_values {
        query_string = false

        cookies {
            forward = "none"
        }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
    }

    logging_config {
        include_cookies = false
        bucket          = aws_s3_bucket.cloud_resume_website_logging_bucket.bucket_regional_domain_name
        prefix          = "cloudfront/"
    }

    viewer_certificate {
        acm_certificate_arn = "arn:aws:acm:us-east-1:144131464452:certificate/558543a5-1dc1-4f0e-81bf-333ab1047960"
        ssl_support_method  = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }

    restrictions {
        geo_restriction {
        restriction_type = "whitelist"
            locations        = ["US", "CA", "GB", "DE", "AT"]
        }
    }
}

resource "aws_cloudfront_origin_access_control" "cloud_resume_oac" {
  name                              = "cloud_resume_oac"
  description                       = "OAC policy for the cloud resume website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}