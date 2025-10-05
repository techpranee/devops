###############################################################################
# IAM USER
###############################################################################
resource "aws_iam_user" "certbot_user" {
  name = var.iam_user_name
  tags = {
    Purpose = "DNS Challenge for Nginx Proxy Manager"
  }
}

###############################################################################
# IAM POLICY DOCUMENT (Least Privilege for Route53)
###############################################################################
data "aws_iam_policy_document" "certbot_policy_doc" {
  statement {
    sid    = "AllowDNSChallengeActions"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:GetChange",
      "route53:ChangeResourceRecordSets"
    ]

    resources = ["*"]
  }
}

###############################################################################
# IAM POLICY
###############################################################################
resource "aws_iam_policy" "certbot_policy" {
  name        = "NginxProxyCertbotRoute53Policy"
  description = "Allow minimal Route53 permissions for DNS-01 challenge"
  policy      = data.aws_iam_policy_document.certbot_policy_doc.json
}

###############################################################################
# ATTACH POLICY TO USER
###############################################################################
resource "aws_iam_user_policy_attachment" "certbot_attach" {
  user       = aws_iam_user.certbot_user.name
  policy_arn = aws_iam_policy.certbot_policy.arn
}

###############################################################################
# ACCESS KEYS
###############################################################################
resource "aws_iam_access_key" "certbot_access_key" {
  user = aws_iam_user.certbot_user.name
}

###############################################################################
# OUTPUTS
###############################################################################
output "certbot_aws_access_key_id" {
  value = aws_iam_access_key.certbot_access_key.id
}

output "certbot_aws_secret_access_key" {
  value     = aws_iam_access_key.certbot_access_key.secret
  sensitive = true
}

output "instructions" {
  value = <<EOT
Paste this into Nginx Proxy Manager → SSL Certificates → DNS Challenge:

[default]
aws_access_key_id = ${aws_iam_access_key.certbot_access_key.id}
aws_secret_access_key = ${aws_iam_access_key.certbot_access_key.secret}

Then issue a wildcard certificate for:
*.20.techpranee.com
20.techpranee.com
EOT
  sensitive = true
}