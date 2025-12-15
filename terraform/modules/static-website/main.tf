terraform {
  required_version = ">= 1.6.0"
}

locals {
  website_domain = var.subdomain_prefix != "" ? "${var.subdomain_prefix}.${var.domain_name}" : var.domain_name
  s3_bucket_name = var.subdomain_prefix != "" ? "${var.subdomain_prefix}-${replace(var.domain_name, ".", "-")}" : replace(var.domain_name, ".", "-")

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "FusionCloudWebsite"
    }
  )
}

# S3 Origin Access Identity for CloudFront
resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "OAI for ${local.website_domain}"
}
