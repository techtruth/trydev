module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = var.domain_name
  acl    = "private"
  force_destroy = true
  tags = {
    Name = var.deployment_tag
  }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = var.deployment_tag
  description                       = "${var.deployment_tag} OAC Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "webapp" {
  origin {
    domain_name              = module.s3_bucket.s3_bucket_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = var.domain_name
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.deployment_tag} static webapp cloudfront s3 dist"
  default_root_object = "index.html"
  aliases             = ["${var.domain_name}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.domain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Name = var.deployment_tag
  }
}

data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    actions = ["s3:GetObject"]

    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.webapp.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.bucket_policy_document.json
}

resource "aws_route53_record" "webapp" {
  name    = var.domain_name
  zone_id =  var.hosted_zone
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.webapp.domain_name
    zone_id                = aws_cloudfront_distribution.webapp.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "github_actions_secret" "set_cloudfront_secret" {
  repository = var.github_repo
  secret_name     = "DEVELOPMENT_CLOUDFRONT"
  plaintext_value = aws_cloudfront_distribution.webapp.id
}

resource "github_actions_secret" "set_s3_secret" {
  repository = var.github_repo
  secret_name     = "DEVELOPMENT_S3"
  plaintext_value = module.s3_bucket.s3_bucket_id
}
