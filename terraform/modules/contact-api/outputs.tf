output "api_endpoint" {
  description = "API Gateway invoke URL for contact form"
  value       = "${aws_api_gateway_deployment.contact.invoke_url}${aws_api_gateway_stage.contact.stage_name}/contact"
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.contact.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.contact.arn
}

output "submissions_bucket_name" {
  description = "S3 bucket name for form submissions"
  value       = aws_s3_bucket.submissions.id
}
