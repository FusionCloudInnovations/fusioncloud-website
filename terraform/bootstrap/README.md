# Terraform Bootstrap

This directory contains the Terraform configuration to bootstrap the remote state backend infrastructure.

## Purpose

Creates the foundational AWS resources needed for Terraform remote state management:
- **S3 Bucket**: Stores Terraform state files with versioning and encryption
- **DynamoDB Table**: Provides state locking to prevent concurrent modifications

## Prerequisites

- AWS CLI configured with admin credentials
- Terraform >= 1.6.0 installed

## Usage

### Initial Bootstrap

This is a **one-time setup** that must be run before deploying any other Terraform configurations.

```bash
# Navigate to bootstrap directory
cd terraform/bootstrap

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### Save Outputs

After applying, save the outputs for configuring other environments:

```bash
# Display backend configuration
terraform output backend_config

# Example output:
# backend "s3" {
#   bucket         = "fusioncloud-terraform-state"
#   region         = "us-east-1"
#   encrypt        = true
#   dynamodb_table = "fusioncloud-terraform-locks"
# }
```

## Resources Created

| Resource | Name | Purpose |
|----------|------|---------|
| S3 Bucket | `fusioncloud-terraform-state` | Stores Terraform state files |
| DynamoDB Table | `fusioncloud-terraform-locks` | Provides state locking |

## Security Features

- **Encryption**: S3 bucket uses AES256 server-side encryption
- **Versioning**: Enabled on S3 bucket for state history and rollback
- **Public Access Block**: All public access blocked on S3 bucket
- **Pay-per-request**: DynamoDB uses on-demand billing for cost efficiency

## State Organization

After bootstrap, state files will be organized as:

```
fusioncloud-terraform-state/
├── website/
│   ├── staging/terraform.tfstate
│   └── production/terraform.tfstate
└── bootstrap/terraform.tfstate (local, optional)
```

**Note**: The bootstrap state file can remain local or be migrated to S3 after creation.

## Cost

Minimal costs (typically < $0.50/month):
- S3 storage: ~$0.023/GB per month
- DynamoDB: Pay-per-request (typically < $0.25/month for small projects)

## Troubleshooting

### Bucket already exists
If you see "BucketAlreadyExists" error:
- The bucket name is globally unique across AWS
- Choose a different `state_bucket_name` in variables

### State locking errors
If you see state locking errors:
- Wait for ongoing operations to complete
- If stuck, manually remove the lock from DynamoDB table (use with caution)

## Next Steps

After bootstrap is complete:
1. Copy the `backend_config` output
2. Update `environments/staging/backend.tf` with the configuration
3. Update `environments/production/backend.tf` with the configuration
4. Run `terraform init` in each environment to migrate state to S3
