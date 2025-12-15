# Note: SES domain verification must be done manually or via separate process
# This is a placeholder for SES configuration

# SES configuration set for tracking
resource "aws_ses_configuration_set" "contact" {
  name = "${var.api_name}-${var.environment}"
}

# Event destination for bounces/complaints
resource "aws_ses_event_destination" "cloudwatch" {
  name                   = "cloudwatch-events"
  configuration_set_name = aws_ses_configuration_set.contact.name
  enabled                = true
  matching_types         = ["bounce", "complaint", "delivery"]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "ses:configuration-set"
    value_source   = "emailHeader"
  }
}
