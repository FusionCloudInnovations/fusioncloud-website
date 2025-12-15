# Contact API Module

Terraform module for deploying a serverless contact form backend with Lambda, API Gateway, and SES.

## Features

- **Serverless Lambda**: Node.js 18 runtime for contact form processing
- **API Gateway**: REST API with CORS support and rate limiting
- **Email Delivery**: Amazon SES for sending contact form emails
- **Form Storage**: S3 bucket for backing up form submissions
- **Cost Optimized**: Pay-per-use, typically < $1/month

## Architecture

```
API Gateway → Lambda → SES (email) + S3 (backup)
```

## Usage

```hcl
module "contact_api" {
  source = "../../modules/contact-api"

  api_name        = "fusioncloud-contact"
  environment     = "staging"
  contact_email   = "info@fusioncloudinnovations.com"
  allowed_origins = ["https://staging.fusioncloudinnovations.com"]
  rate_limit      = 10
  burst_limit     = 20
  lambda_memory   = 512
  lambda_timeout  = 30

  tags = {
    CostCenter = "Marketing"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| api_name | Name of the API | string | "contact-api" | no |
| environment | Environment name (staging/production) | string | - | yes |
| contact_email | Email to receive submissions | string | - | yes |
| allowed_origins | CORS allowed origins | list(string) | - | yes |
| rate_limit | API Gateway rate limit (req/sec) | number | 10 | no |
| burst_limit | API Gateway burst limit | number | 20 | no |
| lambda_memory | Lambda memory (MB) | number | 512 | no |
| lambda_timeout | Lambda timeout (seconds) | number | 30 | no |
| tags | Common resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| api_endpoint | API Gateway invoke URL |
| lambda_function_name | Lambda function name |
| submissions_bucket_name | S3 bucket for submissions |

## Lambda Function

### Environment Variables

The Lambda function receives these environment variables:
- `CONTACT_EMAIL` - Recipient email address
- `SUBMISSIONS_BUCKET` - S3 bucket for backups
- `ENVIRONMENT` - staging or production

### Placeholder Code

The module includes a placeholder Lambda function (`lambda-placeholder.zip`). Replace this with actual implementation:

```javascript
// lambda/contact-form/src/index.js
exports.handler = async (event) => {
  // Parse form data from event.body
  // Validate input
  // Send email via SES
  // Store in S3
  // Return response
};
```

### IAM Permissions

Lambda has permissions for:
- CloudWatch Logs (create log groups/streams)
- SES (send email)
- S3 (put objects in submissions bucket)

## API Gateway

### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /contact | Submit contact form |
| OPTIONS | /contact | CORS preflight |

### CORS Configuration

Allowed methods: POST, OPTIONS
Allowed headers: Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token
Allowed origins: Configured via `allowed_origins` variable

### Rate Limiting

Default limits (configurable):
- Rate: 10 requests/second
- Burst: 20 requests

### Request Format

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "company": "Acme Inc",
  "message": "I'm interested in your services"
}
```

### Response Format

**Success (200):**
```json
{
  "message": "Thank you for contacting us!"
}
```

**Error (400/500):**
```json
{
  "error": "Error message"
}
```

## SES Configuration

### Prerequisites

Before deploying, verify your email in SES:

1. Navigate to AWS SES console
2. Verify email identity: `info@fusioncloudinnovations.com`
3. (Production) Move out of SES sandbox mode

### Configuration Set

The module creates an SES configuration set with CloudWatch event destinations for:
- Bounces
- Complaints
- Delivery confirmations

## S3 Submissions Bucket

### Features

- Server-side encryption (AES256)
- Versioning enabled
- Public access blocked
- Lifecycle policy:
  - Archive to Glacier after 90 days
  - Delete after 365 days

### Storage Format

Submissions are stored as JSON files:
```
contact-api-submissions-staging/
├── 2025/
│   └── 01/
│       └── 15/
│           └── submission-{timestamp}-{uuid}.json
```

## Security

- CORS restricted to allowed origins
- Rate limiting prevents abuse
- Least privilege IAM policies
- All data encrypted at rest
- CloudWatch logs for monitoring

## Cost Breakdown

**Low Traffic (100 submissions/month):**
- Lambda: $0.00 (free tier)
- API Gateway: $0.35
- SES: $0.01
- S3: $0.01
- **Total: ~$0.40/month**

**Higher Traffic (1,000 submissions/month):**
- Lambda: $0.20
- API Gateway: $3.50
- SES: $0.10
- S3: $0.05
- **Total: ~$4/month**

## Deployment

### Initial Setup

1. Deploy infrastructure:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

2. Get API endpoint:
   ```bash
   terraform output api_endpoint
   ```

3. Verify SES email:
   - AWS Console → SES → Email Addresses
   - Verify `info@fusioncloudinnovations.com`

4. Add to frontend environment:
   ```bash
   NEXT_PUBLIC_API_URL=https://xxxxx.execute-api.us-east-1.amazonaws.com/staging
   ```

### Deploy Lambda Function

After creating actual Lambda code:

```bash
# Build Lambda package
cd lambda/contact-form
npm install
zip -r function.zip .

# Update Terraform
cd ../../terraform/modules/contact-api
# Replace lambda-placeholder.zip reference with actual code
terraform apply
```

## Testing

### Test API Endpoint

```bash
curl -X POST https://API_ENDPOINT/staging/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "company": "Test Co",
    "message": "This is a test"
  }'
```

### Expected Response

```json
{
  "message": "Thank you for contacting us!"
}
```

## Monitoring

### CloudWatch Logs

Lambda logs are stored in:
```
/aws/lambda/contact-api-staging
```

Retention: 14 days

### SES Metrics

SES events (bounces, complaints, delivery) are logged to CloudWatch with dimensions:
- Configuration set: `contact-api-staging`

### API Gateway Metrics

Monitor in CloudWatch:
- Request count
- Latency (average, p50, p99)
- 4xx/5xx error rates

## Troubleshooting

### SES email not delivered
- Check SES is out of sandbox mode (production only)
- Verify sender email in SES console
- Check CloudWatch logs for errors

### CORS errors
- Ensure allowed_origins includes your website URL
- Check browser console for specific error
- Verify OPTIONS method is deployed

### Rate limit errors (429)
- Increase rate_limit/burst_limit variables
- Implement exponential backoff in frontend
- Consider caching on frontend

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Resources Created

- `aws_lambda_function` - Contact form handler
- `aws_iam_role` - Lambda execution role
- `aws_iam_role_policy` - Lambda permissions
- `aws_cloudwatch_log_group` - Lambda logs
- `aws_api_gateway_rest_api` - REST API
- `aws_api_gateway_resource` - /contact resource
- `aws_api_gateway_method` - POST and OPTIONS methods
- `aws_api_gateway_integration` - Lambda integration
- `aws_api_gateway_deployment` - API deployment
- `aws_api_gateway_stage` - Environment stage
- `aws_api_gateway_usage_plan` - Rate limiting
- `aws_s3_bucket` - Submissions storage
- `aws_ses_configuration_set` - SES tracking
- `aws_ses_event_destination` - CloudWatch events

## License

MIT
