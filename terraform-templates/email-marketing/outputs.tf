# Primary Domain Outputs
output "primary_domain" {
  description = "Primary SES domain configuration"
  value = {
    domain               = module.ses_domain["primary"].ses_identity_domain
    configuration_set    = module.ses_domain["primary"].configuration_set_name
    mail_from_domain    = module.ses_domain["primary"].mail_from_domain
    sns_topic_arn       = var.create_sns_topics ? module.sns_ses_events["primary"].topic_arn : null
    sns_topic_name      = var.create_sns_topics ? module.sns_ses_events["primary"].topic_name : null
  }
}

# Warm-up Domain 1 Outputs
output "warmup_domain_1" {
  description = "First warm-up SES domain configuration"
  value = {
    domain               = module.ses_domain["warmup1"].ses_identity_domain
    configuration_set    = module.ses_domain["warmup1"].configuration_set_name
    mail_from_domain    = module.ses_domain["warmup1"].mail_from_domain
    sns_topic_arn       = var.create_sns_topics ? module.sns_ses_events["warmup1"].topic_arn : null
    sns_topic_name      = var.create_sns_topics ? module.sns_ses_events["warmup1"].topic_name : null
  }
}

# Warm-up Domain 2 Outputs
output "warmup_domain_2" {
  description = "Second warm-up SES domain configuration"
  value = {
    domain               = module.ses_domain["warmup2"].ses_identity_domain
    configuration_set    = module.ses_domain["warmup2"].configuration_set_name
    mail_from_domain    = module.ses_domain["warmup2"].mail_from_domain
    sns_topic_arn       = var.create_sns_topics ? module.sns_ses_events["warmup2"].topic_arn : null
    sns_topic_name      = var.create_sns_topics ? module.sns_ses_events["warmup2"].topic_name : null
  }
}

# Summary Outputs for Easy Monitoring
output "all_domains_summary" {
  description = "Summary of all configured email domains"
  value = {
    primary_domain    = var.primary_domain
    warmup_domain_1   = var.warmup_domain_1
    warmup_domain_2   = var.warmup_domain_2
    total_domains     = 3
    ses_region        = var.ses_region
  }
}

output "all_sns_topics" {
  description = "All SNS topic ARNs for monitoring setup"
  value = var.create_sns_topics ? {
    primary_topic   = module.sns_ses_events["primary"].topic_arn
    warmup1_topic   = module.sns_ses_events["warmup1"].topic_arn
    warmup2_topic   = module.sns_ses_events["warmup2"].topic_arn
  } : null
}

output "configuration_sets" {
  description = "All SES configuration set names"
  value = {
    primary_config   = module.ses_domain["primary"].configuration_set_name
    warmup1_config   = module.ses_domain["warmup1"].configuration_set_name
    warmup2_config   = module.ses_domain["warmup2"].configuration_set_name
  }
}

# BIMI Outputs
output "bimi_configuration" {
  description = "BIMI configuration details for the primary domain"
  value = var.enable_bimi && var.bimi_svg_url != "" ? {
    enabled        = true
    domain         = var.primary_domain
    bimi_record    = length(module.bimi_primary) > 0 ? module.bimi_primary[0].bimi_record_name : null
    bimi_value     = length(module.bimi_primary) > 0 ? module.bimi_primary[0].bimi_record_value : null
    svg_url        = var.bimi_svg_url
    vmc_url        = var.bimi_vmc_url != "" ? var.bimi_vmc_url : "Not configured"
    selector       = var.bimi_selector
  } : {
    enabled = false
    message = "BIMI is disabled or SVG URL not provided"
  }
}