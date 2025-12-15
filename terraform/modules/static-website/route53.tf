# A record (IPv4) pointing to CloudFront
resource "aws_route53_record" "website_a" {
  zone_id = var.route53_zone_id
  name    = local.website_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

# AAAA record (IPv6) pointing to CloudFront
resource "aws_route53_record" "website_aaaa" {
  count   = var.enable_ipv6 ? 1 : 0
  zone_id = var.route53_zone_id
  name    = local.website_domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}
