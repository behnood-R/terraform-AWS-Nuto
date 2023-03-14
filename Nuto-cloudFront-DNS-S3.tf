provider "aws" {
  region = "us-west-2"
}

resource "aws_route53_zone" "example" {
  name = "example.com"
}

resource "aws_route53_record" "example_alias" {
  name    = "example.com"
  type    = "A"
  zone_id = aws_route53_zone.example.id

  alias {
    name                   = aws_cloudfront_distribution.example.domain_name
    zone_id                = aws_cloudfront_distribution.example.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_cloudfront_distribution" "example" {
  origin {
    domain_name = aws_s3_bucket.example.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.example.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.example.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.example.arn
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_acm_certificate" "example" {
  domain_name       = "example.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_route53_record" "example_validation" {
  name    = aws_acm_certificate.example.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.example.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.example.id
  records = [aws_acm_certificate.example.domain_validation_options.0.resource_record_value]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [aws_route53_record.example_validation.fqdn]

  lifecycle {
    create_before_destroy = true
  }
}
