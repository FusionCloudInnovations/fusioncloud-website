variable "domain_name" {
  description = "Primary domain name (e.g., fusioncloudinnovations.com)"
  type        = string
}

variable "environment" {
  description = "Environment name (staging or production)"
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be staging or production."
  }
}

variable "subdomain_prefix" {
  description = "Subdomain prefix for staging (e.g., 'staging' -> staging.fusioncloudinnovations.com)"
  type        = string
  default     = ""
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_100 = NA/EU, PriceClass_All = global)"
  type        = string
  default     = "PriceClass_100"
}

variable "enable_ipv6" {
  description = "Enable IPv6 for CloudFront distribution"
  type        = bool
  default     = true
}

variable "default_ttl" {
  description = "Default TTL for CloudFront cache (seconds)"
  type        = number
  default     = 3600  # 1 hour
}

variable "max_ttl" {
  description = "Maximum TTL for CloudFront cache (seconds)"
  type        = number
  default     = 86400  # 24 hours
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for the domain"
  type        = string
}
