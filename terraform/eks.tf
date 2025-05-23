###########################################################
######                    EKS                        ######
###########################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "${var.name_prefix}-eks-cluster-${var.env}"
  cluster_version = "1.32"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true

  bootstrap_self_managed_addons = true
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_groups = {
    ce-grp-2-ng = {
      max_size       = 6
      min_size       = 3
      desired_size   = 3
      instance_types = ["t3.medium"]

      tags = {
        Name = "${var.name_prefix}-node-group-${var.env}"
      }
    }
  }
  tags = {
    Name = "${var.name_prefix}-cluster-${var.env}"
  }
}