data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "ses_events" {
  name         = var.name
  display_name = var.display_name != "" ? var.display_name : var.name
  tags         = var.tags
}

# IAM policy document that allows SES to publish to this topic
data "aws_iam_policy_document" "ses_publish_policy" {
  statement {
    sid    = "AllowSESPublish"
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }
    
    actions = [
      "SNS:Publish"
    ]
    
    resources = [
      aws_sns_topic.ses_events.arn
    ]

    # Restrict to your AWS account for security
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    # Allow any configuration set in allowed regions to publish
    dynamic "condition" {
      for_each = var.allow_regions
      content {
        test     = "ArnLike"
        variable = "AWS:SourceArn"
        values   = [
          "arn:aws:ses:${condition.value}:${data.aws_caller_identity.current.account_id}:configuration-set/*"
        ]
      }
    }
  }
}

# Attach the policy to the SNS topic
resource "aws_sns_topic_policy" "ses_events_policy" {
  arn    = aws_sns_topic.ses_events.arn
  policy = data.aws_iam_policy_document.ses_publish_policy.json
}