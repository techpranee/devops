# Example: Multiple Domain Setup for Different Brands/Purposes
# This shows how to deploy multiple email domains with separate SNS topics

# Brand 1 - Marketing Domain
module "brand1_marketing" {
  source = "./terraform-templates/email-marketing"
  
  # Domain Configuration
  identity_domain      = "mail.brand1.com"
  cloudflare_zone_id   = "zone-id-for-brand1-com"
  CLOUDFLARE_API_TOKEN = var.CLOUDFLARE_API_TOKEN
  
  # SNS Configuration
  create_sns_topic = true
  sns_topic_name   = "ses-events-brand1-marketing"
  
  # Tagging
  tags = {
    Brand       = "Brand1"
    Purpose     = "Marketing"
    Environment = "production"
  }
}

# Brand 1 - Transactional Domain  
module "brand1_transactional" {
  source = "./terraform-templates/email-marketing"
  
  # Domain Configuration
  identity_domain      = "tx.brand1.com"
  cloudflare_zone_id   = "zone-id-for-brand1-com"
  CLOUDFLARE_API_TOKEN = var.CLOUDFLARE_API_TOKEN
  
  # SNS Configuration
  create_sns_topic = true
  sns_topic_name   = "ses-events-brand1-transactional"
  
  # Stricter DMARC for transactional emails
  dmarc_policy = "quarantine"
  
  # Tagging
  tags = {
    Brand       = "Brand1"
    Purpose     = "Transactional"
    Environment = "production"
  }
}

# Brand 2 - Marketing Domain
module "brand2_marketing" {
  source = "./terraform-templates/email-marketing"
  
  # Domain Configuration
  identity_domain      = "mail.brand2.io"
  cloudflare_zone_id   = "zone-id-for-brand2-io"
  CLOUDFLARE_API_TOKEN = var.CLOUDFLARE_API_TOKEN
  
  # SNS Configuration
  create_sns_topic = true
  sns_topic_name   = "ses-events-brand2-marketing"
  
  # Tagging
  tags = {
    Brand       = "Brand2"
    Purpose     = "Marketing"
    Environment = "production"
  }
}

# Outputs for monitoring
output "all_sns_topics" {
  description = "All created SNS topic ARNs"
  value = {
    brand1_marketing      = module.brand1_marketing.sns_topic_arn
    brand1_transactional = module.brand1_transactional.sns_topic_arn
    brand2_marketing     = module.brand2_marketing.sns_topic_arn
  }
}

output "all_ses_domains" {
  description = "All configured SES domains"
  value = {
    brand1_marketing      = module.brand1_marketing.ses_identity_domain
    brand1_transactional = module.brand1_transactional.ses_identity_domain
    brand2_marketing     = module.brand2_marketing.ses_identity_domain
  }
}