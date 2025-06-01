data "aws_availability_zones" "available" {
  state = "available"
}


# Caller identity for account ID
data "aws_caller_identity" "current" {}
