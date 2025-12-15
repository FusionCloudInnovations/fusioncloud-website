# Production Environment

Terraform configuration for the FusionCloud Innovations website production environment.

## Overview

This environment deploys the live production website infrastructure:
- Static website hosting (S3 + CloudFront)
- Contact form API (Lambda + API Gateway)
- SSL certificate (ACM)
- DNS records (Route 53)

**Domain:** www.fusioncloudinnovations.com (root domain)

## Prerequisites

1. Bootstrap completed (remote state backend created)
2. Staging environment tested and validated
3. AWS CLI configured with appropriate credentials
4. Terraform >= 1.6.0 installed
5. Route 53 hosted zone exists for fusioncloudinnovations.com
6. SES verified and out of sandbox mode

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

**Critical Review Points:**
- Domain name is correct (no subdomain prefix)
- All resource names indicate "production"
- Rate limits are appropriate for production traffic
- No staging resources will be affected

### 4. Deploy Infrastructure

```bash
terraform apply
```

**Note:** Initial deployment takes ~20-30 minutes due to:
- ACM certificate DNS validation (5-10 min)
- CloudFront distribution creation (15-20 min)

**Important:** Deploying production will update DNS records. Ensure you're ready to switch traffic.

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
PRODUCTION_AWS_ACCESS_KEY_ID = <deployment_access_key_id>
PRODUCTION_AWS_SECRET_ACCESS_KEY = <deployment_secret_access_key>
PRODUCTION_S3_BUCKET = <s3_bucket_name>
PRODUCTION_CLOUDFRONT_DISTRIBUTION_ID = <cloudfront_distribution_id>
PRODUCTION_API_URL = <contact_api_endpoint>
```

## Deployment Workflow

### Manual Deployment (Emergency Only)

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

### Automated Deployment (Preferred)

Push to `main` branch triggers automatic deployment:
1. Run tests (type-check, lint)
2. Build Next.js site
3. Require approval (GitHub Environment protection)
4. Sync to S3
5. Invalidate CloudFront cache

## Verification

### Test Website

```bash
# Check DNS resolution
dig fusioncloudinnovations.com
dig www.fusioncloudinnovations.com

# Check SSL certificate
openssl s_client -connect www.fusioncloudinnovations.com:443 \
  -servername www.fusioncloudinnovations.com

# Check website loads
curl -I https://www.fusioncloudinnovations.com
```

### Test Contact API

```bash
API_URL=$(terraform output -raw contact_api_endpoint)

curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Production Test",
    "email": "test@example.com",
    "message": "Testing production API"
  }'
```

### Monitor

- CloudWatch Logs: `/aws/lambda/fusioncloud-contact-production`
- CloudFront Metrics: AWS Console → CloudFront → Monitoring
- SES Metrics: AWS Console → SES → Sending Statistics

## Cost Estimate

Monthly costs for typical production usage:

**Low Traffic (10K page views/month):**
| Service | Cost |
|---------|------|
| S3 | $0.01 |
| CloudFront | $1.70 |
| Route 53 | $0.50 |
| Lambda | Free tier |
| API Gateway | $0.35 |
| **Total** | **~$2.60/month** |

**Medium Traffic (100K page views/month):**
| Service | Cost |
|---------|------|
| S3 | $0.10 |
| CloudFront | $17.00 |
| Route 53 | $0.50 |
| Lambda | $0.20 |
| API Gateway | $3.50 |
| **Total** | **~$21/month** |

## Updating Infrastructure

### Pre-Deployment Checklist

- [ ] Test changes in staging environment
- [ ] Review Terraform plan output
- [ ] Notify team of planned update
- [ ] Have rollback plan ready
- [ ] Monitor CloudWatch during deployment

### Apply Changes

```bash
terraform plan -out=tfplan
# Review plan carefully
terraform apply tfplan
```

### Rollback Procedure

If deployment causes issues:

```bash
# Option 1: Revert Terraform code
git revert <commit-hash>
terraform plan
terraform apply

# Option 2: Restore from backup
# - Keep previous CloudFront distribution for 24 hours
# - Revert DNS to previous CloudFront domain
# - Restore S3 bucket from versioning
```

## Destroying Infrastructure

**⚠️ DANGER:** This will delete the production website!

```bash
# Double-check you're in production directory
pwd  # Should show: .../terraform/environments/production

# Review what will be destroyed
terraform plan -destroy

# Type "yes" to confirm (requires typing environment name)
terraform destroy
```

**Note:** Consider archiving S3 bucket contents before destroying.

## Differences from Staging

| Feature | Staging | Production |
|---------|---------|------------|
| Domain | staging.fusioncloudinnovations.com | fusioncloudinnovations.com |
| Subdomain Prefix | "staging" | "" (root) |
| API Rate Limit | 10 req/sec | 20 req/sec |
| API Burst Limit | 20 req | 40 req |
| Deployment | Automatic on push | Requires approval |
| SES | Sandbox mode OK | Must be verified, out of sandbox |
| Monitoring | Basic | Enhanced recommended |

## SES Configuration

### Production Requirements

1. **Email Verification:**
   - AWS Console → SES → Verified Identities
   - Verify: info@fusioncloudinnovations.com

2. **Move Out of Sandbox:**
   - AWS Console → SES → Account Dashboard
   - Request production access
   - Provide use case details
   - Wait for approval (usually 24-48 hours)

3. **Reputation Monitoring:**
   - Monitor bounce rate (keep < 5%)
   - Monitor complaint rate (keep < 0.1%)
   - Set up CloudWatch alarms for high rates

## Monitoring & Alerting

### CloudWatch Alarms

Recommended alarms:
- CloudFront 5xx errors > 1%
- Lambda errors > 5
- SES bounce rate > 5%
- API Gateway 4xx errors > 100/hour

### Log Retention

- Lambda logs: 30 days (increase from 14)
- CloudFront access logs: Enable and store in S3
- API Gateway access logs: Consider enabling

## Troubleshooting

### Website Not Loading

1. Check DNS: `dig fusioncloudinnovations.com`
2. Check CloudFront status in AWS Console
3. Check S3 bucket contents
4. Check CloudFront error logs

### Contact Form Not Working

1. Check Lambda logs in CloudWatch
2. Verify SES email verified
3. Check API Gateway CORS configuration
4. Test API endpoint directly with curl

### Slow Website Performance

1. Check CloudFront cache hit ratio
2. Review cache-control headers
3. Consider enabling compression
4. Check origin response time

## File Structure

```
production/
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
- S3 bucket: `fusioncloudinnovations-com`
- CloudFront distribution
- ACM certificate (us-east-1)
- Route 53 A/AAAA records
- IAM deployment user

**Contact API:**
- Lambda function: `fusioncloud-contact-production`
- API Gateway REST API
- S3 submissions bucket
- SES configuration set
- CloudWatch log groups

## Support

For issues or questions:
- Check CloudWatch logs
- Review Terraform state: `terraform show`
- Contact AWS Support (if needed)
- Review staging environment for comparison

## Security Checklist

- [ ] SES email verified
- [ ] IAM deployment user has least privilege
- [ ] S3 buckets are private
- [ ] CloudFront uses HTTPS only
- [ ] API Gateway has rate limiting
- [ ] CloudWatch logs enabled
- [ ] Cost alerts configured
- [ ] State bucket encrypted
- [ ] Access keys stored in GitHub Secrets only
