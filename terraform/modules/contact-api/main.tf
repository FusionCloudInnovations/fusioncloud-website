terraform {
  required_version = ">= 1.6.0"
}

locals {
  function_name = "${var.api_name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "FusionCloudWebsite"
    }
  )
}
