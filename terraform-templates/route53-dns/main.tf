locals {
  # Common tags for all resources
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  })
}

# Route53 Hosted Zone (only create if create_hosted_zone is true)
resource "aws_route53_zone" "this" {
  count = var.create_hosted_zone ? 1 : 0
  
  name          = var.domain_name
  comment       = var.hosted_zone_comment
  force_destroy = var.force_destroy_hosted_zone

  # VPC association for private hosted zones
  dynamic "vpc" {
    for_each = var.zone_type == "private" ? var.vpc_associations : []
    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.vpc_region
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.domain_name}-hosted-zone"
    Type = var.zone_type
  })
}

# Data source to get existing hosted zone if not creating one
data "aws_route53_zone" "existing" {
  count = var.create_hosted_zone ? 0 : 1
  
  name         = var.domain_name
  private_zone = var.zone_type == "private"
}

# Local to determine which hosted zone to use
locals {
  hosted_zone_id = var.create_hosted_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

# Route53 DNS Records
resource "aws_route53_record" "this" {
  for_each = { for record in var.dns_records : "${record.name}-${record.type}" => record }

  zone_id         = local.hosted_zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = each.value.ttl
  allow_overwrite = true

  records = each.value.records

  # Set identifier for weighted, latency-based, failover, or geolocation routing
  set_identifier = each.value.set_identifier

  # Weighted routing policy
  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted_routing_policy != null ? [each.value.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  # Latency-based routing policy
  dynamic "latency_routing_policy" {
    for_each = each.value.latency_routing_policy != null ? [each.value.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  # Failover routing policy
  dynamic "failover_routing_policy" {
    for_each = each.value.failover_routing_policy != null ? [each.value.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  # Geolocation routing policy
  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation_routing_policy != null ? [each.value.geolocation_routing_policy] : []
    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  # Health check ID for routing policies
  health_check_id = each.value.health_check_id

  # Multivalue answer routing
  multivalue_answer_routing_policy = each.value.multivalue_answer_routing_policy
}

# Route53 Alias Records (for AWS resources like ALB, CloudFront, etc.)
resource "aws_route53_record" "alias" {
  for_each = { for record in var.alias_records : "${record.name}-${record.type}" => record }

  zone_id         = local.hosted_zone_id
  name            = each.value.name
  type            = each.value.type
  allow_overwrite = true

  alias {
    name                   = each.value.alias_name
    zone_id                = each.value.alias_zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }

  # Set identifier for routing policies
  set_identifier = each.value.set_identifier

  # Weighted routing policy
  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted_routing_policy != null ? [each.value.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  # Latency-based routing policy
  dynamic "latency_routing_policy" {
    for_each = each.value.latency_routing_policy != null ? [each.value.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  # Failover routing policy
  dynamic "failover_routing_policy" {
    for_each = each.value.failover_routing_policy != null ? [each.value.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  # Geolocation routing policy
  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation_routing_policy != null ? [each.value.geolocation_routing_policy] : []
    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  # Health check ID for routing policies
  health_check_id = each.value.health_check_id

  # Multivalue answer routing
  multivalue_answer_routing_policy = each.value.multivalue_answer_routing_policy
}

# Route53 Health Checks (optional)
resource "aws_route53_health_check" "this" {
  for_each = { for check in var.health_checks : check.reference_name => check }

  fqdn                            = each.value.fqdn
  port                            = each.value.port
  type                            = each.value.type
  resource_path                   = each.value.resource_path
  failure_threshold               = each.value.failure_threshold
  request_interval                = each.value.request_interval
  measure_latency                 = each.value.measure_latency
  invert_healthcheck              = each.value.invert_healthcheck
  insufficient_data_health_status = each.value.insufficient_data_health_status
  enable_sni                      = each.value.enable_sni

  tags = merge(local.common_tags, {
    Name = "${each.value.reference_name}-health-check"
  })
}