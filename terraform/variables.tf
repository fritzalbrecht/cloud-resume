variable "aws_account_id" {
  description = "The AWS account number where the resources will be hosted"
  type        = string
  default     = ""
}

variable "cloudflare_zone_id" {
  description = ""
  type        = string
  default = ""
}

variable "account_id" {
  description = ""
  type        = string
  default = ""
}

variable "domain" {
  description = "T"
  type        = string
  default = "fritzalbrecht.com"
}

variable "acm_cert_arn" {
  description = "ARN of the ACM cert"
  type        = string
  default = ""
}
