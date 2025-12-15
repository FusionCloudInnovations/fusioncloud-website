# S3 backend for Terraform state
# Run bootstrap first to create the backend infrastructure
terraform {
  backend "s3" {
    bucket         = "fusioncloud-terraform-state"
    key            = "website/staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "fusioncloud-terraform-locks"
  }
}
