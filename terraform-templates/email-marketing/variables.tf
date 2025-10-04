# Domain Configuration
variable "primary_domain" {
  description = "Primary domain for email marketing (e.g., mail.yourdomain.com)"
  type        = string
}

variable "warmup_domain_1" {
  description = "First warm-up domain (e.g., mail1.yourdomain.com)"
  type        = string
}

variable "warmup_domain_2" {
  description = "Second warm-up domain (e.g., mail2.yourdomain.com)"
  type        = string
}

variable "ses_region" {
  description = "SES region (e.g., ap-south-1)"
  type        = string
  default     = "ap-south-1"
}

variable "primary_cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the primary domain"
  type        = string
}

variable "warmup1_cloudflare_zone_id" {
  description = "Cloudflare Zone ID for first warm-up domain (if different from primary)"
  type        = string
  default     = ""
}

variable "warmup2_cloudflare_zone_id" {
  description = "Cloudflare Zone ID for second warm-up domain (if different from primary)"
  type        = string
  default     = ""
}

variable "CLOUDFLARE_API_TOKEN" {
  description = "Cloudflare API token for DNS management"
  type        = string
  sensitive   = true
}

# DMARC Configuration
variable "primary_dmarc_policy" {
  description = "DMARC policy for primary domain: none | quarantine | reject"
  type        = string
  default     = "quarantine"
}

variable "warmup_dmarc_policy" {
  description = "DMARC policy for warm-up domains: none | quarantine | reject"
  type        = string
  default     = "none"
}

variable "dmarc_rua" {
  description = "DMARC aggregate reports mailbox (mailto: address supported)"
  type        = string
  default     = "dmarc@example.com"
}

variable "create_mail_from" {
  description = "Whether to create MAIL FROM domain"
  type        = bool
  default     = true
}

variable "mail_from_prefix" {
  description = "MAIL FROM subdomain prefix (e.g., 'mail' -> mail.m.hyrefast.ai)"
  type        = string
  default     = "mail"
}

variable "create_config_set" {
  description = "Whether to create SES configuration set"
  type        = bool
  default     = true
}

variable "config_set_name" {
  description = "Custom name for the configuration set"
  type        = string
  default     = null
}

variable "create_sns_topics" {
  description = "Whether to create SNS topics for SES events (one per domain)"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_events" {
  description = "Enable CloudWatch event destination"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}