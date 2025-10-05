# S3 Bucket Configuration Variables

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the bucket will be created"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Bucket Configuration Options
variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Enable server-side encryption for the S3 bucket"
  type        = bool
  default     = true
}

variable "encryption_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
  
  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "Encryption algorithm must be either 'AES256' or 'aws:kms'."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (required if encryption_algorithm is aws:kms)"
  type        = string
  default     = ""
}

variable "enable_public_read" {
  description = "Enable public read access to the bucket"
  type        = bool
  default     = false
}

variable "enable_static_website" {
  description = "Configure bucket for static website hosting"
  type        = bool
  default     = false
}

variable "index_document" {
  description = "Index document for static website hosting"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for static website hosting"
  type        = string
  default     = "error.html"
}

variable "lifecycle_enabled" {
  description = "Enable lifecycle management for the bucket"
  type        = bool
  default     = false
}

variable "lifecycle_transition_days" {
  description = "Number of days after which objects transition to IA storage class"
  type        = number
  default     = 30
}

variable "lifecycle_glacier_days" {
  description = "Number of days after which objects transition to Glacier"
  type        = number
  default     = 90
}

variable "lifecycle_expiration_days" {
  description = "Number of days after which objects expire (0 to disable)"
  type        = number
  default     = 0
}

variable "enable_cors" {
  description = "Enable CORS configuration for the bucket"
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allowed_methods" {
  description = "List of allowed HTTP methods for CORS"
  type        = list(string)
  default     = ["GET", "POST"]
}

variable "cors_allowed_headers" {
  description = "List of allowed headers for CORS"
  type        = list(string)
  default     = ["*"]
}

# CloudFront Configuration
variable "enable_cloudfront" {
  description = "Enable CloudFront distribution for the S3 bucket"
  type        = bool
  default     = false
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"
  
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "Price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

variable "cloudfront_default_ttl" {
  description = "Default TTL for CloudFront cache (in seconds)"
  type        = number
  default     = 86400  # 24 hours
}

variable "cloudfront_max_ttl" {
  description = "Maximum TTL for CloudFront cache (in seconds)"
  type        = number
  default     = 31536000  # 1 year
}

variable "cloudfront_compress" {
  description = "Enable CloudFront compression"
  type        = bool
  default     = true
}

variable "cloudfront_allowed_methods" {
  description = "Allowed HTTP methods for CloudFront"
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "cloudfront_cached_methods" {
  description = "Cached HTTP methods for CloudFront"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "tags" {
  description = "Additional tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}

###############################################################################
# TWENTY CRM BUCKET VARIABLES
###############################################################################
variable "twenty_crm_bucket_name" {
  description = "Name of the Twenty CRM S3 bucket"
  type        = string
  default     = "twenty-crm-uploads"
}

variable "twenty_crm_iam_user_name" {
  description = "IAM user name for Twenty CRM S3 access"
  type        = string
  default     = "twenty-crm-storage"
}