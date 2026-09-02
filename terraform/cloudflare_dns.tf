terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4"
    }
    # This config was written against AWS provider v5. Nothing here is pinned in
    # git (.terraform.lock.hcl is gitignored), so every `terraform init` resolves
    # to the newest release -- currently v6.x, which REMOVED `stage_name` from
    # aws_api_gateway_deployment. Pinning back to 5.x is what lets `destroy` run
    # against the same schema the state was written with. Do not bump this to
    # v6 just to make the plan validate; see the note in api_gw.tf.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "aws_api_gateway_domain_name" "cdk_domain_name" {
  domain_name = "api-cdk.fritzalbrecht.com"
}

resource "cloudflare_record" "terraform_cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = "tf"
  value   = aws_cloudfront_distribution.cloud_resume_website_distribution_terraform.domain_name
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

resource "cloudflare_record" "api_gateway_invoke_url_record_tf" {
  zone_id = var.cloudflare_zone_id
  name    = "api-tf"
  value   = aws_api_gateway_domain_name.fritzalbrecht.regional_domain_name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "api_gateway_invoke_url_record_cdk" {
  zone_id = var.cloudflare_zone_id
  name    = "api-cdk"
  value   = data.aws_api_gateway_domain_name.cdk_domain_name.regional_domain_name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}