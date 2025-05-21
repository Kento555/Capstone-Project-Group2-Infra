data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_route53_zone" "primary" {
  name = "sctp-sandbox.com"
}