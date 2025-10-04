#!/bin/bash

# Terraform SES Domain Setup Script
# This script helps you set up environment variables securely

echo "🚀 Setting up Terraform environment for SES Domain module"
echo "=================================================="

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Creating .env file template..."
    cat > .env << EOF
# Cloudflare Configuration
export TF_VAR_CLOUDFLARE_API_TOKEN="your-cloudflare-api-token-here"

# AWS Configuration (optional if using AWS CLI profile)
# export AWS_ACCESS_KEY_ID="your-aws-access-key"
# export AWS_SECRET_ACCESS_KEY="your-aws-secret-key"
# export AWS_DEFAULT_REGION="ap-south-1"

# Multi-Domain Configuration (Primary + 2 Warm-up Domains)
export TF_VAR_primary_domain="mail.yourdomain.com"
export TF_VAR_warmup_domain_1="mail1.yourdomain.com"
export TF_VAR_warmup_domain_2="mail2.yourdomain.com"

# AWS Configuration
export TF_VAR_ses_region="ap-south-1"

# Cloudflare Zone Configuration
export TF_VAR_primary_cloudflare_zone_id="your-primary-zone-id"
export TF_VAR_warmup_cloudflare_zone_id=""  # Leave empty if same as primary, or set different zone ID

# DMARC Configuration (stricter for primary, relaxed for warm-up)
export TF_VAR_primary_dmarc_policy="quarantine"   # quarantine | reject for production
export TF_VAR_warmup_dmarc_policy="none"          # none for warm-up domains
export TF_VAR_dmarc_rua="dmarc@yourdomain.com"

# SNS Configuration (creates separate topics for each domain)
export TF_VAR_create_sns_topics="true"
export TF_VAR_enable_cloudwatch_events="true"

# Optional: Custom tags
# export TF_VAR_tags='{"Environment":"production","Project":"email-marketing"}'
EOF
    echo "✅ Created .env file. Please edit it with your actual values."
    echo "⚠️  Remember: .env is gitignored and won't be committed to version control."
else
    echo "✅ .env file already exists."
fi

echo ""
echo "📝 Next steps:"
echo "1. Edit .env file with your actual domain values:"
echo "   - Replace 'yourdomain.com' with your actual domains"
echo "   - Set your Cloudflare API token"
echo "   - Set primary_cloudflare_zone_id for your primary domain"
echo "   - Set warmup_cloudflare_zone_id if warm-up domains are in different zone"
echo "2. Run: source .env"
echo "3. Run: terraform init"
echo "4. Run: terraform plan"
echo "5. Run: terraform apply"
echo ""
echo "📧 Email Domain Strategy:"
echo "- Primary: Production email campaigns"
echo "- Warmup1 & Warmup2: Reputation building and backup"
echo ""
echo "🔒 Security tip: Never commit .env or *.tfvars files to git!"