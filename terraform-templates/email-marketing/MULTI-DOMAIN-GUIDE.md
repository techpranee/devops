# 📧 Multi-Domain Email Marketing Setup Guide

## 🎯 Domain Strategy: Primary + Warm-up Domains

This configuration deploys a robust email marketing infrastructure with:

### **Primary Domain** (`mail.yourdomain.com`)
- ✅ **Production email campaigns**
- ✅ **Stricter DMARC policy** (quarantine/reject)
- ✅ **Dedicated SNS topic** for monitoring
- ✅ **Full authentication** (SPF, DKIM, DMARC)

### **Warm-up Domains** (`mail1.yourdomain.com`, `mail2.yourdomain.com`)
- 🔥 **IP/domain reputation building**
- 🔥 **Backup sending capacity**
- 🔥 **Relaxed DMARC policy** (none) during warm-up
- 🔥 **Separate SNS topics** for isolated monitoring

## 🚀 Quick Deployment

```bash
# 1. Set up environment variables
./setup.sh

# 2. Edit .env file with your actual domains
nano .env

# Update these lines:
export TF_VAR_primary_domain="mail.yourdomain.com"
export TF_VAR_warmup_domain_1="mail1.yourdomain.com" 
export TF_VAR_warmup_domain_2="mail2.yourdomain.com"

# 3. Load environment and deploy
source .env
terraform init
terraform plan
terraform apply
```

## 📊 What Gets Created

### **Per Domain (3 total):**
- ✅ SES Domain Identity + DKIM
- ✅ Cloudflare DNS records (SPF, DMARC, DKIM CNAMEs)
- ✅ MAIL FROM subdomain (mail.domain.com)
- ✅ SES Configuration Set
- ✅ SNS Topic for events
- ✅ CloudWatch integration

### **Total Infrastructure:**
- **9 verified domains** (3 main + 3 MAIL FROM + 3 DKIM)
- **3 SNS topics** (isolated event streams)
- **3 configuration sets** (separate tracking)
- **15+ DNS records** (complete authentication)

## 📈 Email Warm-up Strategy

### Phase 1: Initial Setup (Week 1-2)
```bash
# Start with warm-up domains only
# Send 50-100 emails/day to engaged lists
# Monitor bounce/complaint rates via SNS
```

### Phase 2: Volume Ramp (Week 3-4) 
```bash
# Gradually increase to 500-1000 emails/day
# Mix of warm-up and primary domain usage
# Maintain low complaint rates (<0.1%)
```

### Phase 3: Production (Week 5+)
```bash
# Primary domain for main campaigns
# Warm-up domains for backup/overflow
# Full volume email marketing
```

## 🔍 Monitoring Your Domains

### View All Domain Status
```bash
# Check all configured domains
terraform output all_domains_summary

# Get all SNS topic ARNs
terraform output all_sns_topics

# Check configuration sets
terraform output configuration_sets
```

### Individual Domain Details
```bash
# Primary domain info
terraform output primary_domain

# Warm-up domain 1 info  
terraform output warmup_domain_1

# Warm-up domain 2 info
terraform output warmup_domain_2
```

### Set Up SNS Alerts
```bash
# Subscribe to all domain events
aws sns subscribe --topic-arn $(terraform output -raw primary_domain | jq -r '.sns_topic_arn') --protocol email --notification-endpoint alerts@yourdomain.com

aws sns subscribe --topic-arn $(terraform output -raw warmup_domain_1 | jq -r '.sns_topic_arn') --protocol email --notification-endpoint alerts@yourdomain.com

aws sns subscribe --topic-arn $(terraform output -raw warmup_domain_2 | jq -r '.sns_topic_arn') --protocol email --notification-endpoint alerts@yourdomain.com
```

## ⚙️ Configuration Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `primary_domain` | Main production domain | `mail.yourdomain.com` |
| `warmup_domain_1` | First warm-up domain | `mail1.yourdomain.com` |
| `warmup_domain_2` | Second warm-up domain | `mail2.yourdomain.com` |
| `primary_dmarc_policy` | Strict policy for primary | `quarantine` or `reject` |
| `warmup_dmarc_policy` | Relaxed for warm-up | `none` |

## 🛡️ Security & Best Practices

### DMARC Progression
```bash
# Week 1-2: Start with "none" for all domains
primary_dmarc_policy = "none"
warmup_dmarc_policy = "none"

# Week 3-4: Tighten primary domain
primary_dmarc_policy = "quarantine"  
warmup_dmarc_policy = "none"

# Week 5+: Production settings
primary_dmarc_policy = "reject"
warmup_dmarc_policy = "quarantine"
```

### DNS Record Validation
```bash
# Verify SPF records
dig TXT mail.yourdomain.com
dig TXT mail1.yourdomain.com  
dig TXT mail2.yourdomain.com

# Check DMARC records
dig TXT _dmarc.mail.yourdomain.com
dig TXT _dmarc.mail1.yourdomain.com
dig TXT _dmarc.mail2.yourdomain.com
```

## 🚨 Troubleshooting

### Common Issues
1. **DNS Propagation Delays**: Wait up to 48 hours for full propagation
2. **DKIM Verification**: Ensure all 3 DKIM CNAMEs are created per domain
3. **SES Sandbox**: New AWS accounts need to request production access
4. **Bounce/Complaint Monitoring**: Watch SNS topics for delivery issues

### Verification Commands
```bash
# Check SES domain verification status
aws ses get-identity-verification-attributes --identities mail.yourdomain.com mail1.yourdomain.com mail2.yourdomain.com

# List configuration sets
aws sesv2 list-configuration-sets

# Check SNS topics
aws sns list-topics | grep ses-events
```

This multi-domain setup provides robust email infrastructure with proper warm-up capabilities and comprehensive monitoring! 🎯