# Email Marketing Terraform Infrastructure

This Terraform configuration sets up a complete email marketing infrastructure with:
- **AWS SES** domain configuration and authentication
- **SNS topics** for SES event notifications 
- **Cloudflare DNS** management for domain verification
- **Event tracking** with CloudWatch and SNS integration

## 🚀 Quick Start

### 1. Setup Environment
```bash
# Navigate to the email-marketing directory
cd terraform-templates/email-marketing

# Run the setup script
./setup.sh

# Edit the .env file with your actual values
nano .env

# Source the environment variables
source .env
```

### 2. Configure Your Values
Edit the `.env` file created by the setup script:

```bash
# Required: Cloudflare API Token
export TF_VAR_CLOUDFLARE_API_TOKEN="your-cloudflare-api-token"

# Required: Domain Configuration
export TF_VAR_identity_domain="mail.yourdomain.com"
export TF_VAR_ses_region="ap-south-1"
export TF_VAR_cloudflare_zone_id="your-zone-id"
export TF_VAR_dmarc_rua="dmarc@yourdomain.com"
```

### 3. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## 📋 Usage Examples

### Basic Setup - Single Zone (All domains on same root)
```hcl
# All domains under yourdomain.com
primary_domain              = "mail.yourdomain.com"
warmup_domain_1            = "mail1.yourdomain.com"  
warmup_domain_2            = "mail2.yourdomain.com"
primary_cloudflare_zone_id = "zone-id-for-yourdomain-com"
warmup_cloudflare_zone_id  = ""  # Empty = use primary zone

# Common configuration
CLOUDFLARE_API_TOKEN = "your-api-token"
create_sns_topics = true
enable_cloudwatch_events = true
```

### Multi-Zone Setup (Domains on different Cloudflare zones)
```hcl
# Different root domains for warm-up
primary_domain              = "mail.yourdomain.com"
warmup_domain_1            = "mail.warmupdomain1.com"
warmup_domain_2            = "mail.warmupdomain2.com"  
primary_cloudflare_zone_id = "zone-id-for-yourdomain-com"
warmup_cloudflare_zone_id  = "zone-id-for-warmup-domains"

CLOUDFLARE_API_TOKEN = "your-api-token"  # Must have access to both zones
```

### Multiple Domains Setup
```hcl
# For multiple brands/domains, use separate configurations
module "marketing_domain_1" {
  source = "./terraform-templates/email-marketing"
  
  identity_domain = "mail.brand1.com"
  sns_topic_name = "ses-events-brand1"
  tags = { Brand = "Brand1", Environment = "production" }
}

module "transactional_domain_1" {
  source = "./terraform-templates/email-marketing"
  
  identity_domain = "tx.brand1.com" 
  sns_topic_name = "ses-events-tx-brand1"
  tags = { Brand = "Brand1", Type = "Transactional" }
}
```

## 🔐 Security Best Practices

### Environment Variables
- **Never commit** `.env`, `*.tfvars`, or `terraform.tfstate` files
- Use environment variables prefixed with `TF_VAR_` for Terraform variables
- Source your `.env` file before running Terraform commands

### Cloudflare API Token
1. Go to Cloudflare Dashboard → My Profile → API Tokens
2. Create a custom token with:
   - **Permissions**: `Zone:Edit`, `Zone Settings:Edit`
   - **Zone Resources**: Include your specific zone
3. Use this token as `CLOUDFLARE_API_TOKEN`

### AWS Credentials
- Use AWS CLI profiles: `aws configure --profile your-profile`
- Or use IAM roles if running on EC2
- Avoid hardcoding access keys

## 📁 Architecture & File Structure

### 🏗️ Infrastructure Components
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cloudflare    │────│   AWS SES       │────│   SNS Topics    │
│   DNS Records   │    │   Domain +      │    │   Event         │
│   (DKIM,SPF,    │    │   Config Set    │    │   Notifications │
│    DMARC)       │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   CloudWatch    │
                       │   Metrics &     │
                       │   Monitoring    │
                       └─────────────────┘
```

### 📁 File Structure
```
email-marketing/
├── main.tf                   # Root configuration
├── variables.tf              # Root variables
├── outputs.tf               # Root outputs  
├── providers.tf             # Provider configurations
├── modules/
│   ├── ses-domain/          # SES + Cloudflare DNS module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── providers.tf
│   └── sns-ses-events/      # SNS topics for SES events
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── providers.tf
├── setup.sh                 # Environment setup script
├── terraform.tfvars.example # Example configuration
└── README.md               # This documentation
```

## 🛠 Variables

### Required Variables
| Name | Description | Type | Example |
|------|-------------|------|---------|
| `identity_domain` | Domain for sending emails | `string` | `"mail.yourdomain.com"` |
| `primary_cloudflare_zone_id` | Cloudflare Zone ID for primary domain | `string` | `"abc123def456"` |
| `warmup_cloudflare_zone_id` | Zone ID for warm-up domains (optional) | `string` | `""` (uses primary if empty) |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token | `string` | `"your-api-token"` |

### Optional Variables
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `ses_region` | AWS SES region | `string` | `"ap-south-1"` |
| `dmarc_policy` | DMARC policy | `string` | `"none"` |
| `dmarc_rua` | DMARC reports email | `string` | `"dmarc@example.com"` |
| `create_mail_from` | Create MAIL FROM domain | `bool` | `true` |
| `mail_from_prefix` | MAIL FROM subdomain prefix | `string` | `"mail"` |
| `create_sns_topic` | Create SNS topic for events | `bool` | `true` |
| `sns_topic_name` | Custom SNS topic name | `string` | `""` (auto-generated) |
| `enable_cloudwatch_events` | Enable CloudWatch events | `bool` | `true` |
| `tags` | Common resource tags | `map(string)` | `{}` |

## 📤 Outputs

| Name | Description |
|------|-------------|
| `ses_identity_domain` | The verified SES domain |
| `configuration_set_name` | SES configuration set name |
| `mail_from_domain` | MAIL FROM domain (if created) |
| `sns_topic_arn` | ARN of the SNS topic for SES events |
| `sns_topic_name` | Name of the SNS topic |

## 🔔 SNS Event Integration

### Automatic SNS Topic Creation
When `create_sns_topic = true`, the module automatically:
- Creates an SNS topic with proper naming
- Sets up IAM policies for SES to publish events
- Configures SES to send all email events to SNS

### SES Events Published to SNS
- **SEND** - Email sent successfully
- **BOUNCE** - Email bounced
- **COMPLAINT** - Spam complaint received  
- **DELIVERY** - Email delivered to recipient
- **REJECT** - Email rejected by SES
- **OPEN** - Email opened by recipient
- **CLICK** - Link clicked in email
- **RENDERING_FAILURE** - Template rendering failed

### Setting Up SNS Subscribers
After deployment, add subscribers to your SNS topic:

```bash
# Subscribe an email to receive notifications
aws sns subscribe \
  --topic-arn "$(terraform output -raw sns_topic_arn)" \
  --protocol email \
  --notification-endpoint your-alerts@domain.com

# Subscribe a Lambda function for processing
aws sns subscribe \
  --topic-arn "$(terraform output -raw sns_topic_arn)" \
  --protocol lambda \
  --notification-endpoint arn:aws:lambda:region:account:function:process-ses-events
```

## 🚨 Important Notes

1. **DNS Propagation**: DNS changes may take up to 48 hours to fully propagate
2. **SES Sandbox**: New AWS accounts start in SES sandbox mode
3. **Domain Verification**: Verify your domain in SES console after applying
4. **Region Consistency**: Ensure your SES region matches your infrastructure

## 🔍 Troubleshooting

### Common Issues
1. **Cloudflare API errors**: Check your API token permissions
2. **SES verification failed**: Ensure DNS records are properly created
3. **Permission denied**: Verify AWS credentials and IAM permissions

### Useful Commands
```bash
# Check Terraform state
terraform show

# Refresh state
terraform refresh

# Destroy infrastructure
terraform destroy
```