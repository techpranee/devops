# IAM Certbot User for Nginx Proxy Manager

This Terraform configuration creates an IAM user with minimal Route53 permissions for DNS-01 challenges in Nginx Proxy Manager.

## What it creates:

- **IAM User**: `nginx-proxy-certbot` with appropriate tags
- **IAM Policy**: Least-privilege policy allowing only necessary Route53 actions for DNS challenges
- **Access Keys**: AWS access keys for the IAM user
- **Policy Attachment**: Attaches the policy to the user

## Required Route53 Permissions:

The policy allows these actions on all Route53 resources:
- `route53:ListHostedZones`
- `route53:ListHostedZonesByName`
- `route53:GetChange`
- `route53:ChangeResourceRecordSets`

## Usage:

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Plan the changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Copy the output credentials to Nginx Proxy Manager SSL configuration

## Nginx Proxy Manager Setup:

After running Terraform, use the output `instructions` to configure DNS challenge credentials in Nginx Proxy Manager.

## Security Notes:

- The IAM user has minimal required permissions only
- Access keys are generated and displayed in outputs
- Store the credentials securely
- Rotate access keys regularly