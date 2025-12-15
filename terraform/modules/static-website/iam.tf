# IAM user for GitHub Actions deployment
resource "aws_iam_user" "deployment" {
  name = "${local.s3_bucket_name}-deployment"
  path = "/fusioncloud-website/"

  tags = merge(
    local.common_tags,
    {
      Name = "GitHub Actions Deployment User"
    }
  )
}

# IAM policy for deployment (S3 sync + CloudFront invalidation)
resource "aws_iam_user_policy" "deployment" {
  name = "DeploymentPolicy"
  user = aws_iam_user.deployment.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.website.arn
      },
      {
        Sid    = "S3ObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.website.arn}/*"
      },
      {
        Sid    = "CloudFrontInvalidation"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation"
        ]
        Resource = aws_cloudfront_distribution.website.arn
      }
    ]
  })
}

# Access key for deployment (to be stored in GitHub Secrets)
resource "aws_iam_access_key" "deployment" {
  user = aws_iam_user.deployment.name
}
