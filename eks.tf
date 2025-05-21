resource "aws_iam_role" "ce-grp-2-eks" {
  name = "${var.env}-${var.eks_name}-ce-grp-2-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ce-grp-2-eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.ce-grp-2-eks.name
}

resource "aws_eks_cluster" "ce-grp-2-eks" {
  name     = "${var.env}-${var.eks_name}"
  version  = var.eks_version
  role_arn = aws_iam_role.ce-grp-2-eks.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true

    subnet_ids = [
      aws_subnet.ce-grp-2-private_zone1.id,
      aws_subnet.ce-grp-2-private_zone2.id
    ]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.ce-grp-2-eks]
}

resource "aws_eks_addon" "ce-grp-2-vpc_cni" {
  cluster_name = aws_eks_cluster.ce-grp-2-eks.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "ce-grp-2-coredns" {
  cluster_name = aws_eks_cluster.ce-grp-2-eks.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "ce-grp-2-kube_proxy" {
  cluster_name = aws_eks_cluster.ce-grp-2-eks.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "ce-grp-2-eks_pod_identity" {
  cluster_name = aws_eks_cluster.ce-grp-2-eks.name
  addon_name   = "eks-pod-identity-agent"
}


