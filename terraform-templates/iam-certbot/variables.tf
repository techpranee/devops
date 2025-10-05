# IAM Certbot Configuration Variables

variable "iam_user_name" {
  description = "Name of the IAM user for certbot"
  type        = string
  default     = "nginx-proxy-certbot"
}