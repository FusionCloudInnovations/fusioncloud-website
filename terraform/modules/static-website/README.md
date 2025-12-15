# Static Website Module

Terraform module for deploying a static website to AWS with S3, CloudFront, ACM, and Route 53.

## Features

- **S3 Static Hosting**: Private bucket with CloudFront OAI access
- **Global CDN**: CloudFront distribution with SSL/TLS
- **SSL Certificate**: Automatic ACM certificate with DNS validation
- **DNS Management**: Route 53 A/AAAA records
- **CI/CD Ready**: IAM user with deployment credentials
- **Cost Optimized**: ~$2-5/month for typical traffic

## Architecture

```
Route 53 (DNS) → CloudFront (CDN + SSL) → S3 Bucket (Private)
```

## Usage

```hcl
module "website" {
  source = "../../modules/static-website"

  providers = {
    aws.us_east_1 = aws.us_east_1  # Required for ACM certificate
  }

  domain_name             = "fusioncloudinnovations.com"
  subdomain_prefix        = "staging"  # Optional, leave empty for root domain
  environment             = "staging"
  route53_zone_id         = "Z0123456789ABCDEFGHIJ"
  cloudfront_price_class  = "PriceClass_100"
  enable_ipv6             = true
  default_ttl             = 3600
  max_ttl                 = 86400

  tags = {
    CostCenter = "Marketing"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| domain_name | Primary domain name | string | - | yes |
| environment | Environment name (staging/production) | string | - | yes |
| route53_zone_id | Route 53 hosted zone ID | string | - | yes |
| subdomain_prefix | Subdomain prefix (e.g., "staging") | string | "" | no |
| cloudfront_price_class | CloudFront price class | string | "PriceClass_100" | no |
| enable_ipv6 | Enable IPv6 support | bool | true | no |
| default_ttl | Default cache TTL (seconds) | number | 3600 | no |
| max_ttl | Maximum cache TTL (seconds) | number | 86400 | no |
| tags | Common resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| s3_bucket_name | S3 bucket name for deployment |
| cloudfront_distribution_id | CloudFront distribution ID for cache invalidation |
| website_url | Full website URL |
| deployment_user_access_key_id | AWS access key for CI/CD |
| deployment_user_secret_access_key | AWS secret key for CI/CD (sensitive) |

## Security

- S3 bucket is private with CloudFront OAI access only
- All public access blocked via bucket policy
- Server-side encryption (AES256) enabled
- HTTPS enforced via CloudFront
- Least privilege IAM policy for deployment user

## Cost Breakdown

**Low Traffic (10K page views/month):**
- S3: $0.01
- CloudFront: $1.70
- Route 53: $0.50
- **Total: ~$2.25/month**

**Higher Traffic (100K page views/month):**
- S3: $0.10
- CloudFront: $17.00
- Route 53: $0.50
- **Total: ~$18/month**

## Deployment

### Initial Setup

1. Deploy infrastructure:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

2. Get deployment credentials:
   ```bash
   terraform output deployment_user_access_key_id
   terraform output -raw deployment_user_secret_access_key
   ```

3. Add credentials to GitHub Secrets:
   - `STAGING_AWS_ACCESS_KEY_ID`
   - `STAGING_AWS_SECRET_ACCESS_KEY`
   - `STAGING_S3_BUCKET`
   - `STAGING_CLOUDFRONT_DISTRIBUTION_ID`

### Deploy Website

Using AWS CLI:
```bash
# Build Next.js site
npm run build

# Sync to S3
aws s3 sync out/ s3://BUCKET_NAME/ --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id DISTRIBUTION_ID \
  --paths "/*"
```

Using GitHub Actions (automated):
- Push to staging/main branch
- CI/CD pipeline automatically builds and deploys

## Caching Strategy

**Static Assets (JS/CSS/Images):**
- Cache-Control: `public, max-age=31536000, immutable`
- CloudFront TTL: 24 hours max

**HTML Files:**
- Cache-Control: `public, max-age=3600`
- CloudFront TTL: 1 hour default

**Cache Invalidation:**
- Triggered automatically by CI/CD pipeline
- Invalidates all paths (`/*`) on deployment

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Providers

| Name | Alias | Purpose |
|------|-------|---------|
| aws | default | Main AWS provider |
| aws | us_east_1 | ACM certificates (CloudFront requirement) |

## Resources Created

- `aws_s3_bucket` - Website content storage
- `aws_s3_bucket_versioning` - S3 versioning
- `aws_s3_bucket_lifecycle_configuration` - Cleanup policies
- `aws_s3_bucket_server_side_encryption_configuration` - Encryption
- `aws_s3_bucket_public_access_block` - Block public access
- `aws_s3_bucket_policy` - CloudFront OAI access
- `aws_s3_bucket_website_configuration` - Website config
- `aws_cloudfront_distribution` - CDN
- `aws_cloudfront_origin_access_identity` - OAI for S3 access
- `aws_acm_certificate` - SSL/TLS certificate
- `aws_acm_certificate_validation` - Certificate validation
- `aws_route53_record` - DNS records (A, AAAA, cert validation)
- `aws_iam_user` - Deployment user
- `aws_iam_user_policy` - Deployment permissions
- `aws_iam_access_key` - Deployment credentials

## Troubleshooting

### Certificate validation timeout
- Ensure Route 53 hosted zone is correct
- Check DNS propagation: `dig _acme-challenge.staging.fusioncloudinnovations.com`
- ACM validation can take 5-30 minutes

### CloudFront deployment slow
- CloudFront distribution creation takes 15-20 minutes
- Be patient and don't interrupt `terraform apply`

### S3 bucket name conflict
- Bucket names are globally unique
- Adjust `subdomain_prefix` or use a different naming scheme

## License

MIT
