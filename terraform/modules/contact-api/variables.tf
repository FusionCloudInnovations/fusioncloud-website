variable "api_name" {
  description = "Name of the API"
  type        = string
  default     = "contact-api"
}

variable "environment" {
  description = "Environment name (staging or production)"
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be staging or production."
  }
}

variable "contact_email" {
  description = "Email address to receive contact form submissions"
  type        = string
}

variable "allowed_origins" {
  description = "List of allowed origins for CORS (website URLs)"
  type        = list(string)
}

variable "rate_limit" {
  description = "API Gateway rate limit (requests per second)"
  type        = number
  default     = 10
}

variable "burst_limit" {
  description = "API Gateway burst limit"
  type        = number
  default     = 20
}

variable "lambda_memory" {
  description = "Lambda function memory in MB"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
