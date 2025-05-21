module "alb_controller" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.2.0"

  name = "microservices-alb"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
}