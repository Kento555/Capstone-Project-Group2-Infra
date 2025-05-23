###########################################################
######                    EKS                        ######
###########################################################
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

###########################################################
######                EKS - Nodes                    ######
###########################################################

resource "aws_iam_role" "ce-grp-2-nodes" {
  name = "${var.env}-${var.eks_name}-eks-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# This policy now includes AssumeRoleForPodIdentity for the Pod Identity Agent
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ce-grp-2-nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ce-grp-2-nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ce-grp-2-nodes.name
}

resource "aws_eks_node_group" "ce-grp-2-aws_eks_node_group" {
  cluster_name    = aws_eks_cluster.ce-grp-2-eks.name
  version         = var.eks_version
  node_group_name = "general"
  node_role_arn   = aws_iam_role.ce-grp-2-nodes.arn

  subnet_ids = [
    aws_subnet.ce-grp-2-private_zone1.id,
    aws_subnet.ce-grp-2-private_zone2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
