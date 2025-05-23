###########################################################
######                    VPC                        ######
###########################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8.1"

  name = "${var.name_prefix}-vpc-${var.env}"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  public_subnet_names  = ["${var.name_prefix}-public-1a--${var.env}", "${var.name_prefix}--public-1b--${var.env}", "${var.name_prefix}--public-1c--${var.env}"]
  private_subnet_names = ["${var.name_prefix}-private-1a--${var.env}", "${var.name_prefix}--private-1b--${var.env}", "${var.name_prefix}--private-1c--${var.env}"]

  enable_dns_hostnames = true

  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true

  tags = {
    Terraform = "true"
  }
}