module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.2.0"

  domain_name = "avengers.sctp-sandbox.com"
  zone_id     = data.aws_route53_zone.primary.zone_id
  validate_certificate = true
}