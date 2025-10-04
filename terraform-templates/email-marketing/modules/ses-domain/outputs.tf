output "ses_identity_domain" {
  value = aws_ses_domain_identity.this.domain
}

output "configuration_set_name" {
  value = var.create_config_set ? aws_sesv2_configuration_set.this[0].configuration_set_name : null
}

output "mail_from_domain" {
  value = var.create_mail_from ? local.mail_from_domain : null
}
