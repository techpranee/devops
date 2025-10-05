# Route53 DNS Configuration Variables

variable "domain_name" {
  description = "The domain name for the Route53 hosted zone"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources will be created"
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

# Hosted Zone Configuration
variable "create_hosted_zone" {
  description = "Whether to create a new hosted zone or use an existing one"
  type        = bool
  default     = true
}

variable "zone_type" {
  description = "Type of hosted zone (public or private)"
  type        = string
  default     = "public"
  
  validation {
    condition     = contains(["public", "private"], var.zone_type)
    error_message = "Zone type must be either 'public' or 'private'."
  }
}

variable "hosted_zone_comment" {
  description = "Comment for the hosted zone"
  type        = string
  default     = "Managed by Terraform"
}

variable "force_destroy_hosted_zone" {
  description = "Whether to force destroy the hosted zone even if it contains records"
  type        = bool
  default     = false
}

# VPC associations for private hosted zones
variable "vpc_associations" {
  description = "List of VPC associations for private hosted zones"
  type = list(object({
    vpc_id     = string
    vpc_region = string
  }))
  default = []
}

# DNS Records Configuration
variable "dns_records" {
  description = "List of DNS records to create"
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
    
    # Optional routing policy configurations
    set_identifier = optional(string)
    
    weighted_routing_policy = optional(object({
      weight = number
    }))
    
    latency_routing_policy = optional(object({
      region = string
    }))
    
    failover_routing_policy = optional(object({
      type = string # PRIMARY or SECONDARY
    }))
    
    geolocation_routing_policy = optional(object({
      continent   = optional(string)
      country     = optional(string)
      subdivision = optional(string)
    }))
    
    health_check_id                   = optional(string)
    multivalue_answer_routing_policy  = optional(bool)
  }))
  default = []
}

# Alias Records Configuration (for AWS resources)
variable "alias_records" {
  description = "List of alias records to create for AWS resources"
  type = list(object({
    name                   = string
    type                   = string
    alias_name             = string
    alias_zone_id          = string
    evaluate_target_health = bool
    
    # Optional routing policy configurations
    set_identifier = optional(string)
    
    weighted_routing_policy = optional(object({
      weight = number
    }))
    
    latency_routing_policy = optional(object({
      region = string
    }))
    
    failover_routing_policy = optional(object({
      type = string # PRIMARY or SECONDARY
    }))
    
    geolocation_routing_policy = optional(object({
      continent   = optional(string)
      country     = optional(string)
      subdivision = optional(string)
    }))
    
    health_check_id                   = optional(string)
    multivalue_answer_routing_policy  = optional(bool)
  }))
  default = []
}

# Health Checks Configuration
variable "health_checks" {
  description = "List of health checks to create"
  type = list(object({
    reference_name                      = string
    fqdn                               = string
    port                               = number
    type                               = string # HTTP, HTTPS, HTTP_STR_MATCH, HTTPS_STR_MATCH, TCP
    resource_path                      = optional(string)
    failure_threshold                  = optional(number)
    request_interval                   = optional(number)
    measure_latency                    = optional(bool)
    invert_healthcheck                 = optional(bool)
    insufficient_data_health_status    = optional(string)
    enable_sni                         = optional(bool)
  }))
  default = []
}

# Common Tags
variable "tags" {
  description = "A map of additional tags to add to all resources"
  type        = map(string)
  default     = {}
}