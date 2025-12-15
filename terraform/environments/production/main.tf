terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary AWS provider (for most resources)
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "production"
      ManagedBy   = "Terraform"
      Project     = "FusionCloudWebsite"
    }
  }
}

# Secondary provider for ACM certificates (CloudFront requires us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "production"
      ManagedBy   = "Terraform"
      Project     = "FusionCloudWebsite"
    }
  }
}

# Static website module
module "website" {
  source = "../../modules/static-website"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  domain_name            = var.domain_name
  subdomain_prefix       = ""  # Use root domain for production
  environment            = "production"
  route53_zone_id        = var.route53_zone_id
  cloudfront_price_class = "PriceClass_100"
  enable_ipv6            = true
  default_ttl            = 3600
  max_ttl                = 86400

  tags = {
    CostCenter = "Marketing"
  }
}

# Contact API module
module "contact_api" {
  source = "../../modules/contact-api"

  api_name        = "fusioncloud-contact"
  environment     = "production"
  contact_email   = var.contact_email
  allowed_origins = ["https://${var.domain_name}"]
  rate_limit      = 20  # Higher limit for production
  burst_limit     = 40
  lambda_memory   = 512
  lambda_timeout  = 30

  tags = {
    CostCenter = "Marketing"
  }
}
