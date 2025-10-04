output "topic_arn" {
  description = "ARN of the created SNS topic"
  value       = aws_sns_topic.ses_events.arn
}

output "topic_name" {
  description = "Name of the created SNS topic"
  value       = aws_sns_topic.ses_events.name
}

output "topic_id" {
  description = "ID of the created SNS topic"
  value       = aws_sns_topic.ses_events.id
}