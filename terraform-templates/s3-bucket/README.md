# S3 Bucket Terraform Template

A comprehensive Terraform template for creating AWS S3 buckets with various configuration options.

## Features

✅ **Security & Compliance**
- Server-side encryption (AES256 or KMS)
- Public access blocking (configurable)
- Bucket versioning
- Secure bucket policies

✅ **Website Hosting**
- Static website hosting configuration
- Custom index and error documents
- CORS configuration for web applications

✅ **Lifecycle Management**
- Automatic transition to IA and Glacier storage classes
- Object expiration policies
- Incomplete multipart upload cleanup

✅ **Monitoring & Management**
- Comprehensive tagging strategy
- Detailed outputs for integration
- Support for notifications (extensible)

## Quick Start

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Customize your configuration:**
   ```bash
   # Edit .env file with your specific values
   export TF_VAR_bucket_name="my-unique-bucket-name"
   export TF_VAR_project_name="MyProject"
   export TF_VAR_environment="dev"
   ```

3. **Initialize and apply:**
   ```bash
   source .env
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Options

### Basic Configuration

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `bucket_name` | Globally unique bucket name | - | ✅ |
| `project_name` | Project identifier | - | ✅ |
| `aws_region` | AWS region | `ap-south-1` | ❌ |
| `environment` | Environment (dev/staging/prod) | `dev` | ❌ |

### Security Options

| Variable | Description | Default |
|----------|-------------|---------|
| `enable_encryption` | Enable server-side encryption | `true` |
| `encryption_algorithm` | Encryption type (AES256/aws:kms) | `AES256` |
| `enable_versioning` | Enable object versioning | `false` |
| `enable_public_read` | Allow public read access | `false` |

### Website Hosting

| Variable | Description | Default |
|----------|-------------|---------|
| `enable_static_website` | Enable static website hosting | `false` |
| `index_document` | Default index file | `index.html` |
| `error_document` | Error page file | `error.html` |
| `enable_cors` | Enable CORS configuration | `false` |

### Lifecycle Management

| Variable | Description | Default |
|----------|-------------|---------|
| `lifecycle_enabled` | Enable lifecycle policies | `false` |
| `lifecycle_transition_days` | Days to IA storage | `30` |
| `lifecycle_glacier_days` | Days to Glacier storage | `90` |
| `lifecycle_expiration_days` | Days to object expiration | `0` (disabled) |

## Usage Examples

### 1. Basic Private Bucket
```hcl
module "document_storage" {
  source = "./terraform-templates/s3-bucket"
  
  bucket_name  = "my-documents-2025"
  project_name = "DocumentStorage"
  environment  = "prod"
  
  enable_versioning = true
  enable_encryption = true
}
```

### 2. Public Website Bucket
```hcl
module "company_website" {
  source = "./terraform-templates/s3-bucket"
  
  bucket_name  = "mycompany-website"
  project_name = "Website"
  
  enable_public_read    = true
  enable_static_website = true
  enable_cors          = true
  
  cors_allowed_origins = ["https://mycompany.com"]
}
```

### 3. Archive Bucket with Lifecycle
```hcl
module "data_archive" {
  source = "./terraform-templates/s3-bucket"
  
  bucket_name  = "data-archive-2025"
  project_name = "DataArchive"
  
  enable_versioning = true
  lifecycle_enabled = true
  
  lifecycle_transition_days = 30
  lifecycle_glacier_days    = 90
  lifecycle_expiration_days = 2555  # 7 years
}
```

## Security Best Practices

🔒 **Default Security Stance:**
- Public access is **blocked by default**
- Server-side encryption is **enabled by default**
- Versioning is **disabled by default** (enable for important data)

🛡️ **Recommendations:**
- Always use encryption for sensitive data
- Enable versioning for critical business data
- Use lifecycle policies to optimize storage costs
- Review public access settings carefully
- Implement bucket policies for fine-grained access control

## Outputs

The template provides comprehensive outputs:

- **Basic Info:** `bucket_name`, `bucket_arn`, `bucket_region`
- **Endpoints:** `bucket_domain_name`, `website_endpoint`
- **Configuration Status:** `versioning_enabled`, `encryption_enabled`, etc.

## Cost Optimization

💰 **Storage Classes:**
- **Standard:** Frequently accessed data
- **Standard-IA:** Infrequently accessed (after 30 days)
- **Glacier:** Archive storage (after 90 days)
- **Expiration:** Automatic deletion (configurable)

💡 **Tips:**
- Use lifecycle policies to automatically transition data
- Enable incomplete multipart upload cleanup
- Monitor storage metrics and adjust policies
- Consider Intelligent Tiering for variable access patterns

## Advanced Configuration

### KMS Encryption
```bash
export TF_VAR_encryption_algorithm="aws:kms"
export TF_VAR_kms_key_id="arn:aws:kms:region:account:key/key-id"
```

### Custom CORS Policy
```bash
export TF_VAR_cors_allowed_origins='["https://app.mycompany.com", "https://admin.mycompany.com"]'
export TF_VAR_cors_allowed_methods='["GET", "POST", "PUT", "DELETE"]'
```

### Custom Tags
```hcl
tags = {
  Owner       = "DataTeam"
  CostCenter  = "Engineering"
  Compliance  = "SOX"
  Environment = var.environment
}
```

## Troubleshooting

### Common Issues

**Bucket name conflicts:**
- Bucket names must be globally unique
- Use timestamps or random suffixes
- Follow AWS naming conventions

**Permission errors:**
- Ensure AWS credentials are configured
- Check IAM permissions for S3 operations
- Verify region settings

**Public access errors:**
- Review bucket policy and ACL settings
- Check public access block configuration
- Ensure CloudFront is configured if needed

## Integration Examples

### With CloudFront
```hcl
resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = module.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-${module.website_bucket.bucket_name}"
  }
  # ... CloudFront configuration
}
```

### With Lambda Notifications
```hcl
resource "aws_s3_bucket_notification" "lambda_notification" {
  bucket = module.my_bucket.bucket_name
  
  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
```

This template provides a solid foundation for S3 bucket management with security, cost optimization, and flexibility in mind. 🚀