variable "identity_domain" {
  description = "Domain or subdomain you'll send from (e.g., m.hyrefast.ai)."
  type        = string
}

variable "ses_region" {
  description = "SES region (e.g., ap-south-1)."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID where DNS records will be created."
  type        = string
}

variable "create_spf" {
  type    = bool
  default = true
}

variable "dmarc_policy" {
  description = "DMARC policy: none | quarantine | reject"
  type        = string
  default     = "none"
}

variable "dmarc_rua" {
  description = "DMARC aggregate reports mailbox (mailto: address supported)."
  type        = string
  default     = "dmarc@example.com"
}

variable "create_mail_from" {
  type    = bool
  default = true
}

variable "mail_from_prefix" {
  description = "MAIL FROM subdomain prefix (e.g., 'mail' -> mail.m.hyrefast.ai)."
  type        = string
  default     = "mail"
}

variable "create_config_set" {
  type    = bool
  default = true
}

variable "config_set_name" {
  type    = string
  default = null
}

variable "event_destinations" {
  description = "Optional SES v2 config-set destinations."
  type = object({
    enable_sns        = optional(bool, false)
    sns_topic_arn     = optional(string, null)
    enable_firehose   = optional(bool, false)
    firehose_arn      = optional(string, null)
    enable_cloudwatch = optional(bool, false)
  })
  default = {}
}



