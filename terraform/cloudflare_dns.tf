terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_record" "terraform_cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = "tf"
  value   = "${aws_cloudfront_distribution.cloud_resume_website_distribution_terraform.domain_name}"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "cdk_cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = "cdk"
  value   = "d23h5vvz5n9iln.cloudfront.net"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "edge_lambda_cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  value   = "d3t0rjqw9dgp0m.cloudfront.net"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "api_gateway_terraform_dns" {
  zone_id = var.cloudflare_zone_id
  name    = "api"
  value   = "${aws_api_gateway_domain_name.fritzalbrecht.cloudfront_domain_name}"
  type    = "CNAME"
  ttl     = 1
  proxied = false
}
