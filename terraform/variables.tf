variable "aws_account_id" {
  description = "The AWS account number where the resources will be hosted"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudfare DNS zone ID"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "domain" {
  description = "Domain name root"
  type        = string
  default = "fritzalbrecht.com"
}

variable "acm_cert_arn" {
  description = "ARN of the ACM cert"
  type        = string
}

variable "cloudflare_api_token" {
  description = "The Cloudflare API Token for authentication"
  type        = string
}

variable "cloudflare_email" {
  description = "The Cloudflare email for authentication"
  type        = string
  default     = "fritzalbrecht2@gmail.com"
}