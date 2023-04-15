resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.deployment_tag
  }
}

resource "aws_route53_zone" "webapp" {
  name = var.domain_name
}

resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  type            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  zone_id         = aws_route53_zone.webapp.zone_id
  records         = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    "${aws_route53_record.cert_validation.fqdn}"
  ]

  timeouts {
    create = "60m"
  }
}
