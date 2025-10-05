# Route53 Hosted Zone Outputs
output "hosted_zone_id" {
  description = "The hosted zone ID"
  value       = var.create_hosted_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

output "hosted_zone_arn" {
  description = "The hosted zone ARN"
  value       = var.create_hosted_zone ? aws_route53_zone.this[0].arn : data.aws_route53_zone.existing[0].arn
}

output "hosted_zone_name" {
  description = "The hosted zone name"
  value       = var.create_hosted_zone ? aws_route53_zone.this[0].name : data.aws_route53_zone.existing[0].name
}

output "name_servers" {
  description = "List of name servers for the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.this[0].name_servers : data.aws_route53_zone.existing[0].name_servers
}

# DNS Records Outputs
output "dns_records" {
  description = "Map of DNS records created"
  value = {
    for k, v in aws_route53_record.this : k => {
      name    = v.name
      type    = v.type
      ttl     = v.ttl
      records = v.records
      fqdn    = v.fqdn
    }
  }
}

output "alias_records" {
  description = "Map of alias records created"
  value = {
    for k, v in aws_route53_record.alias : k => {
      name = v.name
      type = v.type
      fqdn = v.fqdn
      alias = {
        name    = v.alias[0].name
        zone_id = v.alias[0].zone_id
      }
    }
  }
}

# Health Checks Outputs
output "health_checks" {
  description = "Map of health checks created"
  value = {
    for k, v in aws_route53_health_check.this : k => {
      id   = v.id
      arn  = v.arn
      fqdn = v.fqdn
      port = v.port
      type = v.type
    }
  }
}

# Domain Information
output "domain_name" {
  description = "The domain name"
  value       = var.domain_name
}

output "zone_type" {
  description = "The type of hosted zone (public or private)"
  value       = var.zone_type
}