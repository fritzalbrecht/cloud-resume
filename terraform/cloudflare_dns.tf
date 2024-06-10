terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}

resource "cloudflare_record" "terraform_cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = "tf"
  value   = "${aws_cloudfront_distribution.cloud_resume_website_distribution_terraform.domain_name}"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "api_gateway_domain_cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = "${aws_api_gateway_domain_name.api_gateway_domain_name.cloudfront_domain_name}"
  value   = "${aws_api_gateway_domain_name.api_gateway_domain_name.cloudfront_zone_id}"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "api_gateway_get_visitors_cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = "get"
  value   = "${aws_api_gateway_deployment.cloud_resume_website_visitor_count_rest_api_deployment.invoke_url}path1"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "api_gateway_post_visitors_cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = "post"
  value   = "${aws_api_gateway_deployment.cloud_resume_website_visitor_count_rest_api_deployment.invoke_url}path2"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}