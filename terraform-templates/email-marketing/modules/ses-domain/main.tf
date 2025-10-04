locals {
  mail_from_domain = "${var.mail_from_prefix}.${var.identity_domain}"
  cs_name          = coalesce(var.config_set_name, replace(var.identity_domain, ".", "-"))
}

# ---------- AWS SES: identity + DKIM (+ optional MAIL FROM) ----------
resource "aws_ses_domain_identity" "this" {
  domain = var.identity_domain
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

resource "aws_ses_domain_mail_from" "this" {
  count                  = var.create_mail_from ? 1 : 0
  domain                 = aws_ses_domain_identity.this.domain
  mail_from_domain       = local.mail_from_domain
  behavior_on_mx_failure = "UseDefaultValue"
}

# ---------- SES v2 Configuration Set (optional) ----------
resource "aws_sesv2_configuration_set" "this" {
  count                   = var.create_config_set ? 1 : 0
  configuration_set_name  = local.cs_name

  reputation_options { reputation_metrics_enabled = true }
  delivery_options   { tls_policy = "REQUIRE" }
}

resource "aws_sesv2_configuration_set_event_destination" "sns" {
  count                  = var.create_config_set && try(var.event_destinations.enable_sns, false) ? 1 : 0
  configuration_set_name = aws_sesv2_configuration_set.this[0].configuration_set_name
  event_destination_name = "sns"
  
  event_destination {
    enabled              = true
    matching_event_types = ["SEND","REJECT","BOUNCE","COMPLAINT","DELIVERY","OPEN","CLICK","RENDERING_FAILURE"]
    sns_destination { 
      topic_arn = var.event_destinations.sns_topic_arn 
    }
  }
}

resource "aws_sesv2_configuration_set_event_destination" "firehose" {
  count                  = var.create_config_set && try(var.event_destinations.enable_firehose, false) ? 1 : 0
  configuration_set_name = aws_sesv2_configuration_set.this[0].configuration_set_name
  event_destination_name = "firehose"
  
  event_destination {
    enabled              = true
    matching_event_types = ["SEND","REJECT","BOUNCE","COMPLAINT","DELIVERY","OPEN","CLICK","RENDERING_FAILURE"]
    kinesis_firehose_destination {
      delivery_stream_arn = var.event_destinations.firehose_arn
      iam_role_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ses-firehose-role"
    }
  }
}

resource "aws_sesv2_configuration_set_event_destination" "cloudwatch" {
  count                  = var.create_config_set && try(var.event_destinations.enable_cloudwatch, false) ? 1 : 0
  configuration_set_name = aws_sesv2_configuration_set.this[0].configuration_set_name
  event_destination_name = "cloudwatch"
  
  event_destination {
    enabled              = true
    matching_event_types = ["SEND","REJECT","BOUNCE","COMPLAINT","DELIVERY","OPEN","CLICK","RENDERING_FAILURE"]
    cloud_watch_destination {
      dimension_configuration {
        default_dimension_value = var.identity_domain
        dimension_name          = "ses-identity"
        dimension_value_source  = "MESSAGE_TAG"
      }
    }
  }
}

data "aws_caller_identity" "current" {}

# ---------- Cloudflare DNS (proxied = false) ----------
# SPF on sending subdomain
resource "cloudflare_dns_record" "spf" {
  count   = var.create_spf ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = var.identity_domain
  type    = "TXT"
  content = "v=spf1 include:amazonses.com ~all"
  ttl     = 300
  proxied = false
}

# DMARC (_dmarc.<subdomain>)
resource "cloudflare_dns_record" "dmarc" {
  zone_id = var.cloudflare_zone_id
  name    = "_dmarc.${var.identity_domain}"
  type    = "TXT"
  content = "v=DMARC1; p=${var.dmarc_policy}; rua=mailto:${var.dmarc_rua}; fo=1"
  ttl     = 300
  proxied = false
}

# DKIM (3 CNAMEs)
resource "cloudflare_dns_record" "dkim" {
  count   = 3
  zone_id = var.cloudflare_zone_id
  name    = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}._domainkey.${var.identity_domain}"
  type    = "CNAME"
  content = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}.dkim.amazonses.com"
  ttl     = 600
  proxied = false
}

# MAIL FROM MX + TXT on mail.<subdomain> (optional, but recommended)
resource "cloudflare_dns_record" "mail_from_mx" {
  count   = var.create_mail_from ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = local.mail_from_domain
  type    = "MX"
  content = "feedback-smtp.${var.ses_region}.amazonses.com"
  ttl     = 300
  priority = 10
  proxied = false
}

resource "cloudflare_dns_record" "mail_from_spf" {
  count   = var.create_mail_from ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = local.mail_from_domain
  type    = "TXT"
  content = "v=spf1 include:amazonses.com -all"
  ttl     = 300
  proxied = false
}
