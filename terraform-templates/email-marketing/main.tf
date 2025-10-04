locals {
  # Common tags for all resources
  common_tags = merge(var.tags, {
    Service   = "SES"
    Component = "EmailMarketing"
  })
  
  # Determine zone IDs for each domain (fallback to primary if not specified)
  warmup1_zone_id = var.warmup1_cloudflare_zone_id != "" ? var.warmup1_cloudflare_zone_id : var.primary_cloudflare_zone_id
  warmup2_zone_id = var.warmup2_cloudflare_zone_id != "" ? var.warmup2_cloudflare_zone_id : var.primary_cloudflare_zone_id
  
  # Define all domains to configure
  domains = {
    primary = {
      domain              = var.primary_domain
      purpose            = "Primary"
      dmarc_policy       = var.primary_dmarc_policy
      config_set_name    = "${replace(var.primary_domain, ".", "-")}-primary"
      cloudflare_zone_id = var.primary_cloudflare_zone_id
    }
    warmup1 = {
      domain              = var.warmup_domain_1
      purpose            = "Warmup1"
      dmarc_policy       = var.warmup_dmarc_policy
      config_set_name    = "${replace(var.warmup_domain_1, ".", "-")}-warmup1"
      cloudflare_zone_id = local.warmup1_zone_id
    }
    warmup2 = {
      domain              = var.warmup_domain_2
      purpose            = "Warmup2"
      dmarc_policy       = var.warmup_dmarc_policy
      config_set_name    = "${replace(var.warmup_domain_2, ".", "-")}-warmup2"
      cloudflare_zone_id = local.warmup2_zone_id
    }
  }
}

# Create SNS topics for each domain
module "sns_ses_events" {
  for_each = var.create_sns_topics ? local.domains : {}
  source   = "./modules/sns-ses-events"
  
  name          = "ses-events-${replace(each.value.domain, ".", "-")}"
  display_name  = "SES Events for ${each.value.domain} (${each.value.purpose})"
  allow_regions = [var.ses_region]
  tags = merge(local.common_tags, {
    Domain  = each.value.domain
    Purpose = each.value.purpose
  })
}

# Create SES domain configurations
module "ses_domain" {
  for_each = local.domains
  source   = "./modules/ses-domain"
  
  # Domain configuration
  identity_domain    = each.value.domain
  ses_region        = var.ses_region
  cloudflare_zone_id = each.value.cloudflare_zone_id
  
  # DMARC configuration
  dmarc_policy = each.value.dmarc_policy
  dmarc_rua    = var.dmarc_rua
  
  # MAIL FROM configuration
  create_mail_from = var.create_mail_from
  mail_from_prefix = var.mail_from_prefix
  
  # Configuration set
  create_config_set = var.create_config_set
  config_set_name   = each.value.config_set_name
  
  # Event destinations
  event_destinations = {
    enable_sns        = var.create_sns_topics
    sns_topic_arn     = var.create_sns_topics ? module.sns_ses_events[each.key].topic_arn : ""
    enable_firehose   = false  # Can be enabled later
    firehose_arn      = ""
    enable_cloudwatch = var.enable_cloudwatch_events
  }
}