variable "name" {
  description = "Name of the SNS topic for SES events"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the SNS topic"
  type        = map(string)
  default     = {}
}

variable "allow_regions" {
  description = "AWS regions where SES can publish from (usually just your SES region)"
  type        = list(string)
  default     = ["ap-south-1"]
}

variable "display_name" {
  description = "Display name for the SNS topic"
  type        = string
  default     = ""
}