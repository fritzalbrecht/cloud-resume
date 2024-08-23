variable "aws_account_id" {
  description = "The AWS account number where the resources will be hosted"
  type        = string
  default     = "144131464452"
}

variable "cloudflare_zone_id" {
  description = ""
  type        = string
  default = "4ad1e09b8af79a38d234bba31357d744"
}

variable "account_id" {
  description = ""
  type        = string
  default = "854d529325fb50920ea4eab1ccb64654"
}

variable "domain" {
  description = "T"
  type        = string
  default = "fritzalbrecht.com"
}

variable "acm_cert_arn" {
  description = "ARN of the ACM cert"
  type        = string
  default = "arn:aws:acm:us-east-1:144131464452:certificate/558543a5-1dc1-4f0e-81bf-333ab1047960"
}
