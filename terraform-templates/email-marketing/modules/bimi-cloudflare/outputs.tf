output "bimi_record_name" {
  description = "The full BIMI DNS record name"
  value       = cloudflare_dns_record.bimi_txt.name
}

output "bimi_record_value" {
  description = "The BIMI TXT record value"
  value       = cloudflare_dns_record.bimi_txt.content
}

output "bimi_record_id" {
  description = "Cloudflare DNS record ID for BIMI"
  value       = cloudflare_dns_record.bimi_txt.id
}