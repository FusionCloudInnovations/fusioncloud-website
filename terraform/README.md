# FusionCloud Website - Terraform Infrastructure

Complete infrastructure as code (IaC) for the FusionCloud Innovations marketing website, built with Terraform and deployed to AWS.

## Overview

This Terraform configuration manages:
- **Static Website Hosting**: S3 + CloudFront + ACM + Route 53
- **Contact Form API**: Lambda + API Gateway + SES
- **Remote State**: S3 backend with DynamoDB locking
- **CI/CD Credentials**: IAM users for GitHub Actions deployment

**Estimated Cost:** $2-5/month for typical traffic

## Architecture

```
Route 53 (DNS)
    ↓
CloudFront Distribution (CDN + SSL/TLS)
    ↓
S3 Bucket (Static Content)

Contact Form:
API Gateway → Lambda → SES (email) + S3 (backups)
```

## Directory Structure

```
terraform/
├── modules/
│   ├── static-website/        # S3, CloudFront, ACM, Route53, IAM
│   └── contact-api/           # Lambda, API Gateway, SES, S3
├── environments/
│   ├── staging/               # Staging environment (staging.fusioncloudinnovations.com)
│   └── production/            # Production environment (fusioncloudinnovations.com)
├── bootstrap/                 # Remote state backend setup (S3 + DynamoDB)
└── README.md                  # This file
```

## Getting Started

### Prerequisites

1. **AWS Account** with admin access
2. **Terraform** >= 1.6.0 installed
3. **AWS CLI** configured with credentials
4. **Route 53 Hosted Zone** for fusioncloudinnovations.com

### Step 1: Bootstrap Remote State

**Important:** Run this first, before any other Terraform operations.

```bash
# Navigate to bootstrap directory
cd terraform/bootstrap

# Initialize and apply
terraform init
terraform plan
terraform apply

# Save the outputs
terraform output backend_config
```

This creates:
- S3 bucket: `fusioncloud-terraform-state`
- DynamoDB table: `fusioncloud-terraform-locks`

### Step 2: Deploy Staging Environment

```bash
# Navigate to staging environment
cd ../environments/staging

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values:
# - route53_zone_id (from Route 53 console)
# - contact_email

# Initialize (will prompt to migrate state to S3)
terraform init

# Review what will be created
terraform plan

# Deploy infrastructure
terraform apply
```

**Note:** Initial deployment takes ~20-30 minutes due to CloudFront distribution creation.

### Step 3: Configure GitHub Secrets

After deploying staging:

```bash
# Get deployment credentials
terraform output deployment_access_key_id
terraform output -raw deployment_secret_access_key

# Get infrastructure details
terraform output s3_bucket_name
terraform output cloudfront_distribution_id
terraform output contact_api_endpoint
```

Add these to GitHub repository secrets:
- `STAGING_AWS_ACCESS_KEY_ID`
- `STAGING_AWS_SECRET_ACCESS_KEY`
- `STAGING_S3_BUCKET`
- `STAGING_CLOUDFRONT_DISTRIBUTION_ID`
- `STAGING_API_URL`

See `.github/SECRETS.md` for complete instructions.

### Step 4: Test Staging Deployment

```bash
# Push to staging branch to trigger CI/CD
git push origin staging

# Or deploy manually
npm run build
aws s3 sync out/ s3://$(terraform output -raw s3_bucket_name)/ --delete
aws cloudfront create-invalidation --distribution-id $(terraform output -raw cloudfront_distribution_id) --paths "/*"
```

Visit: https://staging.fusioncloudinnovations.com

### Step 5: Deploy Production

Repeat steps 2-4 for production environment:

```bash
cd ../production
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

terraform init
terraform plan
terraform apply

# Add outputs to GitHub Secrets with PRODUCTION_ prefix
```

Visit: https://www.fusioncloudinnovations.com

## Modules

### static-website

Deploys complete static website hosting infrastructure.

**Inputs:**
- `domain_name` - Root domain
- `subdomain_prefix` - Subdomain (e.g., "staging"), empty for root
- `environment` - "staging" or "production"
- `route53_zone_id` - Route 53 hosted zone ID

**Outputs:**
- `s3_bucket_name` - For deployment
- `cloudfront_distribution_id` - For cache invalidation
- `deployment_user_access_key_id` - For CI/CD
- `deployment_user_secret_access_key` - For CI/CD (sensitive)

**Resources Created:**
- S3 bucket (private, versioned, encrypted)
- CloudFront distribution (SSL/TLS, caching)
- ACM certificate (us-east-1, DNS validation)
- Route 53 A/AAAA records
- IAM deployment user (least privilege)

See `modules/static-website/README.md` for details.

### contact-api

Deploys serverless contact form backend.

**Inputs:**
- `api_name` - API name
- `environment` - "staging" or "production"
- `contact_email` - Email to receive submissions
- `allowed_origins` - CORS allowed origins (website URLs)

**Outputs:**
- `api_endpoint` - API Gateway invoke URL
- `lambda_function_name` - For monitoring
- `submissions_bucket_name` - S3 bucket for form backups

**Resources Created:**
- Lambda function (Node.js 18, placeholder code)
- API Gateway REST API (CORS, rate limiting)
- S3 bucket (form submissions)
- SES configuration set
- IAM roles and policies
- CloudWatch log groups

See `modules/contact-api/README.md` for details.

## Environments

### Staging

- **Domain:** staging.fusioncloudinnovations.com
- **Purpose:** Testing before production
- **Auto-deploy:** Push to `staging` branch
- **Rate limits:** 10 req/sec

### Production

- **Domain:** fusioncloudinnovations.com (root)
- **Purpose:** Live website
- **Auto-deploy:** Push to `main` branch (requires approval)
- **Rate limits:** 20 req/sec

## Common Operations

### View Current Infrastructure

```bash
cd terraform/environments/staging
terraform show
terraform output
```

### Update Infrastructure

```bash
# Edit .tf files as needed
terraform plan
terraform apply
```

### Destroy Environment

**Warning:** This deletes all resources!

```bash
terraform plan -destroy
terraform destroy
```

### Format Terraform Code

```bash
# From terraform/ directory
terraform fmt -recursive
```

### Validate Configuration

```bash
terraform validate
```

## State Management

### Remote State

All environments use remote state stored in S3:
```
fusioncloud-terraform-state/
├── website/staging/terraform.tfstate
└── website/production/terraform.tfstate
```

### State Locking

DynamoDB table `fusioncloud-terraform-locks` prevents concurrent modifications.

### State Commands

```bash
# View state
terraform state list

# Show specific resource
terraform state show aws_s3_bucket.website

# Remove resource from state (careful!)
terraform state rm aws_s3_bucket.website

# Import existing resource
terraform import aws_s3_bucket.website bucket-name
```

## Security

### IAM Permissions

**Deployment User** (created by static-website module):
- S3: PutObject, GetObject, DeleteObject (own bucket only)
- CloudFront: CreateInvalidation (own distribution only)
- Least privilege principle

**Terraform User** (manual setup):
- Full permissions for infrastructure creation
- Separate from deployment credentials

### Credentials Storage

- **Never commit:** terraform.tfvars, state files, credentials
- **GitHub Secrets:** Deployment credentials only
- **AWS Secrets Manager:** Consider for SES credentials (future)

### Encryption

- S3: Server-side encryption (AES256)
- State: Encrypted at rest in S3
- HTTPS: Enforced via CloudFront
- DynamoDB: Encrypted at rest

## Cost Optimization

### Current Setup

- **CloudFront:** PriceClass_100 (NA/EU only, saves ~70%)
- **S3 Lifecycle:** Delete old versions after 30 days
- **Lambda:** Right-sized to 512 MB
- **DynamoDB:** Pay-per-request (no provisioned capacity)

### Estimated Costs

**Low Traffic (10K page views/month):**
- S3: $0.01
- CloudFront: $1.70
- Route 53: $0.50
- Lambda: Free tier
- API Gateway: $0.35
- **Total: ~$2.60/month**

**Medium Traffic (100K page views/month):**
- S3: $0.10
- CloudFront: $17.00
- Route 53: $0.50
- Lambda: $0.20
- API Gateway: $3.50
- **Total: ~$21/month**

### Cost Alerts

Set up AWS Cost Explorer alerts:
- $10 threshold
- $25 threshold
- $50 threshold

## Monitoring

### CloudWatch Logs

- Lambda: `/aws/lambda/fusioncloud-contact-{env}`
- Retention: 14 days (staging), 30 days (production)

### CloudWatch Metrics

Monitor:
- CloudFront: Request count, error rate, cache hit ratio
- Lambda: Invocations, errors, duration
- API Gateway: Request count, latency, 4xx/5xx errors

### SES Metrics

Track:
- Bounce rate (keep < 5%)
- Complaint rate (keep < 0.1%)
- Delivery rate (target > 95%)

## Troubleshooting

### Terraform Init Fails

**Issue:** Backend configuration error

**Solution:**
```bash
# Ensure bootstrap is completed first
cd terraform/bootstrap
terraform init
terraform apply

# Then initialize environment
cd ../environments/staging
terraform init
```

### ACM Certificate Validation Timeout

**Issue:** Certificate stuck in "Pending Validation"

**Solution:**
- Verify Route 53 hosted zone ID is correct
- Check DNS propagation: `dig _acme-challenge.staging.fusioncloudinnovations.com`
- Wait 5-30 minutes for validation

### CloudFront Deployment Slow

**Issue:** Terraform apply stuck at CloudFront

**Solution:**
- This is normal - CloudFront takes 15-20 minutes
- Do not interrupt deployment
- Monitor in AWS Console → CloudFront

### State Lock Error

**Issue:** "Error acquiring state lock"

**Solution:**
- Another Terraform operation is running
- Wait for it to complete
- If stuck, check DynamoDB table and remove lock (use with caution)

### S3 Bucket Already Exists

**Issue:** "BucketAlreadyExists" error

**Solution:**
- Bucket names are globally unique
- Module generates unique names automatically
- If conflict, check for previous deployments

## Updating Modules

After modifying modules in `terraform/modules/`:

```bash
cd terraform/environments/staging
terraform init -upgrade
terraform plan
terraform apply
```

## Best Practices

1. **Always run plan before apply**
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

2. **Test in staging first**
   - Never apply directly to production
   - Validate changes in staging environment

3. **Use version control**
   - Commit Terraform code changes
   - Use conventional commits with gitmoji

4. **Document changes**
   - Update README files
   - Add comments to complex resources

5. **Review state regularly**
   - Check for drift: `terraform plan`
   - Clean up orphaned resources

## CI/CD Integration

### GitHub Actions Workflows

- **test.yml**: Run on PRs, validate builds
- **terraform-plan.yml**: Run on Terraform changes
- **deploy-staging.yml**: Auto-deploy to staging
- **deploy-production.yml**: Auto-deploy to production (with approval)

### Deployment Flow

1. Push to `staging` branch
2. GitHub Actions:
   - Run tests (type-check, lint)
   - Build Next.js site
   - Sync to S3
   - Invalidate CloudFront
3. Verify at staging.fusioncloudinnovations.com
4. Merge to `main` for production
5. Approve production deployment
6. Verify at www.fusioncloudinnovations.com

## Support

### Documentation

- Module README files: `terraform/modules/*/README.md`
- Environment README files: `terraform/environments/*/README.md`
- GitHub Secrets: `.github/SECRETS.md`
- Implementation Plan: `docs/IMPLEMENTATION_PLAN.md`

### Resources

- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws
- Terraform Documentation: https://www.terraform.io/docs
- AWS Documentation: https://docs.aws.amazon.com

### Getting Help

1. Check module README files
2. Review Terraform output errors
3. Check AWS Console for resource status
4. Review CloudWatch logs
5. Consult Terraform documentation

## Future Enhancements

Planned improvements:
- [ ] WAF rules for CloudFront
- [ ] Enhanced monitoring and alerting
- [ ] Backup and disaster recovery procedures
- [ ] Multi-region failover
- [ ] Cost optimization automation
- [ ] Infrastructure testing (Terratest)

## License

MIT
