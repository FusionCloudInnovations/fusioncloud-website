output "s3_bucket_name" {
  description = "Name of the S3 bucket for website content"
  value       = aws_s3_bucket.website.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.website.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "website_url" {
  description = "Full website URL"
  value       = local.website_domain
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.website.arn
}

output "deployment_user_access_key_id" {
  description = "Access key ID for deployment user (sensitive)"
  value       = aws_iam_access_key.deployment.id
  sensitive   = false
}

output "deployment_user_secret_access_key" {
  description = "Secret access key for deployment user"
  value       = aws_iam_access_key.deployment.secret
  sensitive   = true
}
