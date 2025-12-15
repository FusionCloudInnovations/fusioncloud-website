# Staging Environment

Terraform configuration for the FusionCloud Innovations website staging environment.

## Overview

This environment deploys a complete staging instance of the website infrastructure:
- Static website hosting (S3 + CloudFront)
- Contact form API (Lambda + API Gateway)
- SSL certificate (ACM)
- DNS records (Route 53)

**Domain:** staging.fusioncloudinnovations.com

## Prerequisites

1. Bootstrap completed (remote state backend created)
2. AWS CLI configured with appropriate credentials
3. Terraform >= 1.6.0 installed
4. Route 53 hosted zone exists for fusioncloudinnovations.com

## Initial Setup

### 1. Configure Variables

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with actual values
# Required:
# - route53_zone_id: Get from Route 53 console
# - contact_email: Email to receive contact form submissions
```

### 2. Initialize Terraform

```bash
terraform init
```

This will:
- Download required providers
- Configure S3 backend for remote state
- Prompt to migrate any local state (if exists)

### 3. Review Plan

```bash
terraform plan
```

Review the resources that will be created:
- S3 buckets (website content + contact form submissions)
- CloudFront distribution
- ACM certificate
- Route 53 records
- Lambda function
- API Gateway
- IAM users and policies

### 4. Deploy Infrastructure

```bash
terraform apply
```

**Note:** Initial deployment takes ~20-30 minutes due to:
- ACM certificate DNS validation (5-10 min)
- CloudFront distribution creation (15-20 min)

## Outputs

After deployment, get important values:

```bash
# Website URL
terraform output website_url

# S3 bucket for deployment
terraform output s3_bucket_name

# CloudFront distribution ID
terraform output cloudfront_distribution_id

# Contact API endpoint
terraform output contact_api_endpoint

# GitHub Actions credentials (sensitive)
terraform output deployment_access_key_id
terraform output -raw deployment_secret_access_key
```

## GitHub Secrets

Add these outputs to GitHub repository secrets for CI/CD:

```bash
STAGING_AWS_ACCESS_KEY_ID = <deployment_access_key_id>
STAGING_AWS_SECRET_ACCESS_KEY = <deployment_secret_access_key>
STAGING_S3_BUCKET = <s3_bucket_name>
STAGING_CLOUDFRONT_DISTRIBUTION_ID = <cloudfront_distribution_id>
STAGING_API_URL = <contact_api_endpoint>
```

## Deployment Workflow

### Manual Deployment

```bash
# Build Next.js site
npm run build

# Sync to S3
aws s3 sync out/ s3://$(terraform output -raw s3_bucket_name)/ --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

### Automated Deployment (GitHub Actions)

Push to `staging` branch triggers automatic deployment:
1. Run tests (type-check, lint)
2. Build Next.js site
3. Sync to S3
4. Invalidate CloudFront cache

## Verification

### Test Website

```bash
# Check DNS resolution
dig staging.fusioncloudinnovations.com

# Check SSL certificate
openssl s_client -connect staging.fusioncloudinnovations.com:443 \
  -servername staging.fusioncloudinnovations.com

# Check website loads
curl -I https://staging.fusioncloudinnovations.com
```

### Test Contact API

```bash
API_URL=$(terraform output -raw contact_api_endpoint)

curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "message": "Test message"
  }'
```

## Cost Estimate

Monthly costs for typical staging usage (low traffic):

| Service | Cost |
|---------|------|
| S3 | $0.01 |
| CloudFront | $1.70 |
| Route 53 | $0.50 |
| Lambda | Free tier |
| API Gateway | $0.35 |
| **Total** | **~$2.60/month** |

## Updating Infrastructure

### Modify Resources

1. Edit .tf files
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply changes

### Update Modules

After modifying modules in `../../modules/`:

```bash
terraform init -upgrade
terraform plan
terraform apply
```

## Destroying Infrastructure

**Warning:** This will delete all staging resources!

```bash
# Review what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy
```

## Troubleshooting

### ACM Certificate Validation Timeout

**Issue:** Certificate stuck in "Pending Validation"

**Solution:**
- Check Route 53 hosted zone ID is correct
- Wait 5-30 minutes for DNS propagation
- Check validation records exist in Route 53

### CloudFront Deployment Slow

**Issue:** `terraform apply` stuck at CloudFront distribution

**Solution:**
- This is normal - CloudFront takes 15-20 minutes
- Do not interrupt the deployment
- Check AWS console for CloudFront status

### S3 Bucket Name Conflict

**Issue:** "BucketAlreadyExists" error

**Solution:**
- Bucket names are globally unique
- Module automatically generates unique name
- If conflict, check if bucket exists from previous deployment

### State Lock Error

**Issue:** "Error acquiring state lock"

**Solution:**
- Another `terraform` operation is running
- Wait for it to complete
- If stuck, check DynamoDB table `fusioncloud-terraform-locks`
- Remove lock entry if confirmed no operations running (use with caution)

## File Structure

```
staging/
├── main.tf                    # Module instantiation
├── variables.tf               # Variable definitions
├── terraform.tfvars          # Variable values (gitignored)
├── terraform.tfvars.example  # Example values (committed)
├── backend.tf                # S3 backend config
├── outputs.tf                # Output values
└── README.md                 # This file
```

## Resources Created

This environment creates:

**Website Infrastructure:**
- S3 bucket: `staging-fusioncloudinnovations-com`
- CloudFront distribution
- ACM certificate (us-east-1)
- Route 53 A/AAAA records
- IAM deployment user

**Contact API:**
- Lambda function: `fusioncloud-contact-staging`
- API Gateway REST API
- S3 submissions bucket
- SES configuration set
- CloudWatch log groups

## Next Steps

1. Deploy production environment
2. Configure GitHub Secrets
3. Test CI/CD pipeline
4. Verify email delivery (SES)
5. Monitor CloudWatch logs
