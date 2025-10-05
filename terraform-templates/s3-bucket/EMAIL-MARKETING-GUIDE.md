# Email Marketing Assets S3 + CloudFront Example

This example creates a private S3 bucket with CloudFront distribution specifically optimized for email marketing assets.

## What This Creates

### 🔒 **Private S3 Bucket**
- **No public access** - secure by default
- **Server-side encryption** (AES256)
- **CORS enabled** for web client access
- **Optimized for email marketing assets**

### 🌍 **CloudFront Distribution**
- **Global CDN** for fast asset delivery
- **HTTPS-only** access (redirect HTTP to HTTPS)
- **Origin Access Control (OAC)** for secure S3 access
- **Optimized cache behaviors** for different asset types

### 📁 **Folder Structure (Recommended)**
```
bucket/
├── assets/          # Email templates, images, CSS (1 year cache)
│   ├── templates/
│   ├── images/
│   └── styles/
├── bimi/           # BIMI SVG files (30 days cache, no compression)
│   └── logo.svg
└── tracking/       # Tracking pixels, analytics assets
```

## Quick Deploy

1. **Configure your bucket name:**
   ```bash
   # Edit .env file
   export TF_VAR_bucket_name="yourcompany-email-assets-$(date +%s)"
   export TF_VAR_project_name="EmailMarketing"
   ```

2. **Deploy the infrastructure:**
   ```bash
   ./deploy.sh apply
   ```

3. **Get your asset URLs:**
   ```bash
   terraform output assets_base_url
   terraform output bimi_assets_url
   ```

## Usage Examples

### Upload BIMI SVG
```bash
# Upload your BIMI logo
aws s3 cp logo.svg s3://your-bucket-name/bimi/company-logo.svg \
  --content-type "image/svg+xml" \
  --cache-control "max-age=2592000"  # 30 days
```

### Upload Email Template Assets
```bash
# Upload email template images
aws s3 cp email-header.jpg s3://your-bucket-name/assets/images/ \
  --cache-control "max-age=31536000"  # 1 year

# Upload CSS files
aws s3 cp email-styles.css s3://your-bucket-name/assets/styles/ \
  --content-type "text/css" \
  --cache-control "max-age=31536000"  # 1 year
```

### Use in Email Templates
```html
<!-- In your HTML email templates -->
<img src="https://d1234567890.cloudfront.net/assets/images/email-header.jpg" 
     alt="Company Logo" width="200" height="50">

<link rel="stylesheet" 
      href="https://d1234567890.cloudfront.net/assets/styles/email-styles.css">
```

### BIMI Configuration
```dns
; Add this to your DNS (use your actual CloudFront domain)
default._bimi.m.yourdomain.com TXT "v=BIMI1; l=https://d1234567890.cloudfront.net/bimi/company-logo.svg"
```

## Benefits

✅ **Security**
- Private bucket with no public access
- Secure CloudFront access via OAC
- HTTPS-only delivery

✅ **Performance**
- Global CDN for fast worldwide delivery
- Optimized caching per asset type
- Compression enabled (except for SVG)

✅ **Email Marketing Optimized**
- Special BIMI asset handling
- CORS configured for web access
- Long cache times for static assets

✅ **Cost Effective**
- PriceClass_100 (North America + Europe)
- Efficient caching reduces origin requests
- No data transfer costs from S3 to CloudFront

## Integration with Email Marketing

### 1. BIMI (Brand Indicators for Message Identification)
```bash
# Your BIMI SVG will be available at:
https://your-cloudfront-domain.net/bimi/company-logo.svg

# Use in your BIMI DNS record:
default._bimi.m.yourdomain.com TXT "v=BIMI1; l=https://your-cloudfront-domain.net/bimi/company-logo.svg"
```

### 2. Email Template Assets
```html
<!-- Reliable, fast-loading images in emails -->
<img src="https://your-cloudfront-domain.net/assets/images/hero-image.jpg" 
     alt="Product Image" style="max-width: 100%; height: auto;">
```

### 3. Tracking Pixels
```html
<!-- Fast-loading tracking pixels -->
<img src="https://your-cloudfront-domain.net/tracking/pixel.gif?campaign=newsletter" 
     width="1" height="1" style="display:none;">
```

## Monitoring & Management

### Cache Invalidation
```bash
# Clear cache for specific files
aws cloudfront create-invalidation \
  --distribution-id YOUR-DISTRIBUTION-ID \
  --paths "/assets/images/updated-logo.jpg"
```

### Analytics
- Use CloudWatch metrics to monitor:
  - Origin requests
  - Cache hit ratio
  - Error rates
  - Popular content

## Security Best Practices

🔒 **Already Implemented:**
- Private S3 bucket (no public access)
- HTTPS-only access
- Origin Access Control (OAC)
- Server-side encryption

🛡️ **Additional Recommendations:**
- Implement CloudFront signed URLs for sensitive content
- Use AWS WAF for additional protection
- Monitor access patterns with CloudTrail
- Set up S3 bucket notifications for unauthorized access attempts

This setup provides enterprise-grade security and performance for your email marketing assets while keeping costs optimized! 🚀