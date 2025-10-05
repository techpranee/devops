output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "ID of the created S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Hosted zone ID of the S3 bucket"
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "bucket_region" {
  description = "Region where the S3 bucket is created"
  value       = aws_s3_bucket.this.region
}

output "website_endpoint" {
  description = "Website endpoint for the S3 bucket (if static website hosting is enabled)"
  value       = var.enable_static_website ? aws_s3_bucket_website_configuration.this[0].website_endpoint : null
}

output "website_domain" {
  description = "Domain of the website endpoint"
  value       = var.enable_static_website ? aws_s3_bucket_website_configuration.this[0].website_domain : null
}

output "bucket_tags" {
  description = "Tags applied to the S3 bucket"
  value       = aws_s3_bucket.this.tags
}

# Security and Configuration Status
output "versioning_enabled" {
  description = "Whether versioning is enabled for the bucket"
  value       = var.enable_versioning
}

output "encryption_enabled" {
  description = "Whether encryption is enabled for the bucket"
  value       = var.enable_encryption
}

output "public_read_enabled" {
  description = "Whether public read access is enabled for the bucket"
  value       = var.enable_public_read
}

output "static_website_enabled" {
  description = "Whether static website hosting is enabled for the bucket"
  value       = var.enable_static_website
}

output "lifecycle_enabled" {
  description = "Whether lifecycle management is enabled for the bucket"
  value       = var.lifecycle_enabled
}

output "cors_enabled" {
  description = "Whether CORS is enabled for the bucket"
  value       = var.enable_cors
}

# CloudFront Outputs
output "cloudfront_enabled" {
  description = "Whether CloudFront is enabled for the bucket"
  value       = var.enable_cloudfront
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.this[0].id : null
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.this[0].arn : null
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.this[0].domain_name : null
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.this[0].hosted_zone_id : null
}

output "cloudfront_status" {
  description = "CloudFront distribution status"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.this[0].status : null
}

# Asset URLs
output "assets_base_url" {
  description = "Base URL for accessing assets (CloudFront domain if enabled, otherwise S3)"
  value = var.enable_cloudfront ? (
    "https://${aws_cloudfront_distribution.this[0].domain_name}"
  ) : (
    var.enable_public_read ? 
    "https://${aws_s3_bucket.this.bucket_domain_name}" :
    "Private bucket - use CloudFront or signed URLs"
  )
}

output "bimi_assets_url" {
  description = "URL for BIMI assets folder"
  value = var.enable_cloudfront ? (
    "https://${aws_cloudfront_distribution.this[0].domain_name}/bimi/"
  ) : (
    var.enable_public_read ?
    "https://${aws_s3_bucket.this.bucket_domain_name}/bimi/" :
    "Private bucket - use CloudFront or signed URLs"
  )
}