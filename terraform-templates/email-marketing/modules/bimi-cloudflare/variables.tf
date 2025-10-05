variable "identity_domain" {
  description = "The domain (or subdomain) whose mail From: aligns with DMARC, e.g., m.hyrefast.ai"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID that contains identity_domain (e.g., hyrefast.ai zone for m.hyrefast.ai)"
  type        = string
}

variable "bimi_selector" {
  description = "BIMI selector label; most deployments use 'default'"
  type        = string
  default     = "default"
}

variable "bimi_svg_url" {
  description = "HTTPS URL to the BIMI SVG (profile/secure-rasterized SVG)"
  type        = string
}

variable "vmc_url" {
  description = "Optional HTTPS URL to your Verified Mark Certificate (PEM). Leave empty if not using VMC yet."
  type        = string
  default     = ""
}