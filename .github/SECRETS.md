# GitHub Secrets Configuration

This document lists all GitHub Secrets required for the CI/CD pipelines.

## How to Add Secrets

1. Navigate to GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add name and value
5. Click "Add secret"

## Required Secrets

### Staging Environment

Add these after deploying staging infrastructure with Terraform:

```bash
# Navigate to staging environment
cd terraform/environments/staging

# After terraform apply, get outputs:
terraform output deployment_access_key_id
terraform output -raw deployment_secret_access_key
terraform output s3_bucket_name
terraform output cloudfront_distribution_id
terraform output contact_api_endpoint
```

**Secrets to create:**

| Secret Name | Source | Description |
|-------------|--------|-------------|
| `STAGING_AWS_ACCESS_KEY_ID` | `deployment_access_key_id` output | AWS access key for deployment |
| `STAGING_AWS_SECRET_ACCESS_KEY` | `deployment_secret_access_key` output | AWS secret key (sensitive) |
| `STAGING_S3_BUCKET` | `s3_bucket_name` output | S3 bucket for website files |
| `STAGING_CLOUDFRONT_DISTRIBUTION_ID` | `cloudfront_distribution_id` output | CloudFront distribution ID |
| `STAGING_API_URL` | `contact_api_endpoint` output | Contact form API endpoint |

### Production Environment

Add these after deploying production infrastructure with Terraform:

```bash
# Navigate to production environment
cd terraform/environments/production

# After terraform apply, get outputs:
terraform output deployment_access_key_id
terraform output -raw deployment_secret_access_key
terraform output s3_bucket_name
terraform output cloudfront_distribution_id
terraform output contact_api_endpoint
```

**Secrets to create:**

| Secret Name | Source | Description |
|-------------|--------|-------------|
| `PRODUCTION_AWS_ACCESS_KEY_ID` | `deployment_access_key_id` output | AWS access key for deployment |
| `PRODUCTION_AWS_SECRET_ACCESS_KEY` | `deployment_secret_access_key` output | AWS secret key (sensitive) |
| `PRODUCTION_S3_BUCKET` | `s3_bucket_name` output | S3 bucket for website files |
| `PRODUCTION_CLOUDFRONT_DISTRIBUTION_ID` | `cloudfront_distribution_id` output | CloudFront distribution ID |
| `PRODUCTION_API_URL` | `contact_api_endpoint` output | Contact form API endpoint |

### Terraform Operations

For Terraform plan workflow on PRs:

| Secret Name | Description |
|-------------|-------------|
| `TERRAFORM_AWS_ACCESS_KEY_ID` | AWS access key with Terraform permissions |
| `TERRAFORM_AWS_SECRET_ACCESS_KEY` | AWS secret key for Terraform |

**Note:** These require broader AWS permissions than deployment keys. Use a dedicated IAM user with appropriate Terraform policies.

## Security Best Practices

1. **Never commit secrets to Git**
   - Secrets are only stored in GitHub repository settings
   - Never hardcode in workflow files

2. **Rotate credentials regularly**
   - Recommended: Every 90 days
   - Update both AWS IAM and GitHub Secrets

3. **Least privilege**
   - Deployment users only have S3 + CloudFront permissions
   - Terraform user has broader infrastructure permissions

4. **Monitor usage**
   - Review GitHub Actions logs regularly
   - Check AWS CloudTrail for API activity

## Verification

After adding secrets, verify by:

1. **Trigger workflow**
   ```bash
   # Push to staging branch
   git push origin staging
   ```

2. **Check Actions tab**
   - Workflow should run successfully
   - No credential errors in logs

3. **Verify deployment**
   - Website updates on CloudFront
   - No 403/404 errors

## Troubleshooting

### Invalid credentials error

**Symptoms:**
- Workflow fails with "403 Access Denied"
- S3 sync or CloudFront invalidation fails

**Solutions:**
1. Verify secret values are correct (no extra spaces)
2. Check IAM user has required permissions
3. Ensure bucket and distribution IDs are correct
4. Verify credentials haven't expired

### Secret not found error

**Symptoms:**
- Workflow fails with "secret not found"
- Environment variable is empty

**Solutions:**
1. Check secret name matches exactly (case-sensitive)
2. Verify secret is created in correct repository
3. For forks: Secrets don't transfer to forks
4. For organization repos: Check organization secrets

## Updating Secrets

To update an existing secret:

1. GitHub → Settings → Secrets and variables → Actions
2. Find the secret in the list
3. Click "Update"
4. Enter new value
5. Click "Update secret"

**Note:** Updated secrets take effect immediately in new workflow runs.

## Environment Protection

For production deployments, consider enabling environment protection rules:

1. GitHub → Settings → Environments
2. Add "production" environment
3. Configure protection rules:
   - Required reviewers (at least 1)
   - Wait timer (5 minutes)
   - Deployment branches (main only)

This adds an approval step before production deployments.

## Emergency Access

In case of compromised credentials:

1. **Immediately:**
   - Delete IAM access keys in AWS Console
   - Delete secrets from GitHub

2. **Then:**
   - Create new IAM access keys
   - Add new secrets to GitHub
   - Verify workflows work with new credentials

3. **Investigate:**
   - Review AWS CloudTrail logs
   - Check GitHub Actions logs
   - Identify potential security breach

## Maintenance Schedule

| Task | Frequency | Last Done | Next Due |
|------|-----------|-----------|----------|
| Rotate deployment keys | Quarterly | - | - |
| Rotate Terraform keys | Quarterly | - | - |
| Review IAM permissions | Quarterly | - | - |
| Audit GitHub Actions logs | Monthly | - | - |

## Contact

For issues with secrets or permissions:
- Check AWS IAM Console
- Review GitHub Actions logs
- Contact repository administrator
