# Website outputs
output "website_url" {
  description = "Staging website URL"
  value       = module.website.website_url
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation"
  value       = module.website.cloudfront_distribution_id
}

output "s3_bucket_name" {
  description = "S3 bucket name for deployment"
  value       = module.website.s3_bucket_name
}

output "deployment_access_key_id" {
  description = "AWS access key ID for GitHub Actions (store in GitHub Secrets)"
  value       = module.website.deployment_user_access_key_id
  sensitive   = false
}

output "deployment_secret_access_key" {
  description = "AWS secret access key for GitHub Actions (store in GitHub Secrets)"
  value       = module.website.deployment_user_secret_access_key
  sensitive   = true
}

# API outputs
output "contact_api_endpoint" {
  description = "Contact API endpoint URL"
  value       = module.contact_api.api_endpoint
}

output "lambda_function_name" {
  description = "Lambda function name for monitoring"
  value       = module.contact_api.lambda_function_name
}
