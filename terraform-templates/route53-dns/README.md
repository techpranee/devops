# Route53 DNS Terraform Template

This Terraform template creates and manages Route53 hosted zones and DNS records in AWS. It supports both public and private hosted zones, various DNS record types, routing policies, and health checks.

## Features

- **Hosted Zone Management**: Create new hosted zones or use existing ones
- **Multiple Record Types**: Support for A, AAAA, CNAME, MX, TXT, SRV, PTR, and other DNS record types
- **Alias Records**: Support for AWS resource aliases (ALB, CloudFront, etc.)
- **Routing Policies**: Weighted, latency-based, failover, geolocation, and multivalue routing
- **Health Checks**: Configure health checks for monitoring DNS endpoints
- **Private Zones**: Support for VPC-associated private hosted zones
- **Flexible Configuration**: Extensive variable configuration for different use cases

## Usage

### Basic Example - Public Hosted Zone with Simple Records

```hcl
module "route53_dns" {
  source = "./terraform-templates/route53-dns"

  domain_name  = "example.com"
  project_name = "my-project"
  environment  = "prod"

  dns_records = [
    {
      name    = "www"
      type    = "A"
      ttl     = 300
      records = ["192.168.1.100"]
    },
    {
      name    = "mail"
      type    = "MX"
      ttl     = 300
      records = ["10 mail.example.com"]
    },
    {
      name    = "blog"
      type    = "CNAME"
      ttl     = 300
      records = ["www.example.com"]
    }
  ]

  tags = {
    Owner = "DevOps Team"
  }
}
```

### Advanced Example - Load Balancer with Health Checks and Failover

```hcl
module "route53_dns_advanced" {
  source = "./terraform-templates/route53-dns"

  domain_name  = "myapp.com"
  project_name = "web-app"
  environment  = "prod"

  # Create alias records for load balancers
  alias_records = [
    {
      name                   = "api"
      type                   = "A"
      alias_name            = "my-alb-123456789.us-west-2.elb.amazonaws.com"
      alias_zone_id         = "Z1D633PJN98FT9"  # ALB zone ID for us-west-2
      evaluate_target_health = true
      set_identifier        = "primary"
      failover_routing_policy = {
        type = "PRIMARY"
      }
      health_check_id = "primary-health-check"
    },
    {
      name                   = "api"
      type                   = "A"
      alias_name            = "my-alb-backup-987654321.us-east-1.elb.amazonaws.com"
      alias_zone_id         = "Z35SXDOTRQ7X7K"  # ALB zone ID for us-east-1
      evaluate_target_health = true
      set_identifier        = "secondary"
      failover_routing_policy = {
        type = "SECONDARY"
      }
    }
  ]

  # Health checks
  health_checks = [
    {
      reference_name      = "primary-health-check"
      fqdn               = "api.myapp.com"
      port               = 443
      type               = "HTTPS"
      resource_path      = "/health"
      failure_threshold  = 3
      request_interval   = 30
    }
  ]

  tags = {
    Environment = "production"
    Application = "web-app"
  }
}
```

### Private Hosted Zone Example

```hcl
module "private_dns" {
  source = "./terraform-templates/route53-dns"

  domain_name = "internal.mycompany.local"
  zone_type   = "private"
  project_name = "internal-services"
  environment  = "prod"

  vpc_associations = [
    {
      vpc_id     = "vpc-12345678"
      vpc_region = "us-west-2"
    }
  ]

  dns_records = [
    {
      name    = "database"
      type    = "A"
      ttl     = 300
      records = ["10.0.1.100"]
    },
    {
      name    = "cache"
      type    = "A"
      ttl     = 300
      records = ["10.0.1.200"]
    }
  ]
}
```

### Weighted Routing Example

```hcl
module "weighted_routing" {
  source = "./terraform-templates/route53-dns"

  domain_name     = "example.com"
  project_name    = "load-balancing"
  environment     = "prod"
  create_hosted_zone = false  # Use existing hosted zone

  dns_records = [
    {
      name           = "api"
      type           = "A"
      ttl            = 60
      records        = ["1.2.3.4"]
      set_identifier = "server-1"
      weighted_routing_policy = {
        weight = 70
      }
    },
    {
      name           = "api"
      type           = "A"
      ttl            = 60
      records        = ["5.6.7.8"]
      set_identifier = "server-2"
      weighted_routing_policy = {
        weight = 30
      }
    }
  ]
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `domain_name` | The domain name for the Route53 hosted zone | `string` | n/a | yes |
| `project_name` | Name of the project | `string` | n/a | yes |
| `aws_region` | AWS region where resources will be created | `string` | `"ap-south-1"` | no |
| `environment` | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| `create_hosted_zone` | Whether to create a new hosted zone or use existing | `bool` | `true` | no |
| `zone_type` | Type of hosted zone (public or private) | `string` | `"public"` | no |
| `hosted_zone_comment` | Comment for the hosted zone | `string` | `"Managed by Terraform"` | no |
| `force_destroy_hosted_zone` | Force destroy hosted zone even with records | `bool` | `false` | no |
| `vpc_associations` | List of VPC associations for private zones | `list(object)` | `[]` | no |
| `dns_records` | List of DNS records to create | `list(object)` | `[]` | no |
| `alias_records` | List of alias records for AWS resources | `list(object)` | `[]` | no |
| `health_checks` | List of health checks to create | `list(object)` | `[]` | no |
| `tags` | A map of additional tags to add to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `hosted_zone_id` | The hosted zone ID |
| `hosted_zone_arn` | The hosted zone ARN |
| `hosted_zone_name` | The hosted zone name |
| `name_servers` | List of name servers for the hosted zone |
| `dns_records` | Map of DNS records created |
| `alias_records` | Map of alias records created |
| `health_checks` | Map of health checks created |
| `domain_name` | The domain name |
| `zone_type` | The type of hosted zone (public or private) |

## Supported DNS Record Types

- **A**: Maps a domain name to an IPv4 address
- **AAAA**: Maps a domain name to an IPv6 address
- **CNAME**: Maps a domain name to another domain name
- **MX**: Mail exchange records for email routing
- **TXT**: Text records for various purposes (SPF, DKIM, etc.)
- **SRV**: Service records for service discovery
- **PTR**: Pointer records for reverse DNS lookups
- **NS**: Name server records
- **SOA**: Start of authority records (managed automatically)

## Routing Policies

### Weighted Routing
Distribute traffic across multiple resources based on assigned weights.

### Latency-based Routing
Route traffic to the resource that provides the lowest latency.

### Failover Routing
Configure active-passive failover between resources.

### Geolocation Routing
Route traffic based on the geographic location of users.

### Multivalue Answer Routing
Return multiple values for a DNS query with health check support.

## Health Checks

The template supports creating health checks for monitoring endpoints:
- HTTP/HTTPS health checks
- TCP health checks
- String matching health checks
- Configurable failure thresholds and check intervals

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform** version >= 1.0
3. **AWS Provider** version ~> 5.0
4. **Appropriate IAM permissions** for Route53 operations

## Required IAM Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:*",
        "route53domains:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Deployment

1. **Clone or copy this template** to your Terraform workspace
2. **Create a `terraform.tfvars`** file with your configuration
3. **Initialize Terraform**:
   ```bash
   terraform init
   ```
4. **Plan the deployment**:
   ```bash
   terraform plan
   ```
5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Important Notes

- **Domain Registration**: This template doesn't register domains. Ensure your domain is registered before creating hosted zones.
- **DNS Propagation**: DNS changes can take up to 48 hours to propagate globally.
- **Private Zones**: For private hosted zones, ensure your VPCs have DNS resolution and DNS hostnames enabled.
- **Health Checks**: Health checks incur additional AWS costs.
- **Existing Zones**: When using existing hosted zones, ensure you have the necessary permissions.

## Common Use Cases

1. **Website Hosting**: Point domain to web servers or CDN
2. **Email Configuration**: Set up MX records for email services
3. **API Endpoints**: Route API traffic with load balancing
4. **Microservices**: Internal service discovery with private zones
5. **Multi-region Deployments**: Latency-based or failover routing
6. **Blue-Green Deployments**: Weighted routing for gradual traffic shifts

## Troubleshooting

### Common Issues

1. **Zone ID not found**: Ensure the hosted zone exists if `create_hosted_zone = false`
2. **Permission denied**: Check IAM permissions for Route53 operations
3. **Invalid record values**: Verify DNS record formats and values
4. **Health check failures**: Ensure endpoints are accessible and responding correctly

### Debugging

Enable Terraform debug logging:
```bash
export TF_LOG=DEBUG
terraform apply
```

## Support

For issues and questions:
1. Check AWS Route53 documentation
2. Review Terraform AWS provider documentation
3. Validate DNS record formats using online tools
4. Test health check endpoints manually before configuration