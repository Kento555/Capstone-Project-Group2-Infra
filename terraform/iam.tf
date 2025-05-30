###########################################################
######                    IAM                        ######
###########################################################

## Policy for ExternalDNS to manage Route53 records

resource "aws_iam_policy" "externaldns" {
  name        = "${var.name_prefix}-ExternalDNSPolicy-${var.env}"
  description = "Policy for ExternalDNS to manage Route53 records"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets"
        ],
        Resource = ["arn:aws:route53:::hostedzone/*"]
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        Resource = ["*"]
      }
    ]
  })
}

## IAM Role for ExternalDNS

resource "aws_iam_role" "externaldns" {
  name = "${var.name_prefix}-ExternalDNSRole-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = module.eks.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:external-dns:external-dns", ## make sure the part after serviceaccount matches the namespace where external-dns is deployed
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "externaldns_attach" {
  role       = aws_iam_role.externaldns.name
  policy_arn = aws_iam_policy.externaldns.arn
}

resource "aws_iam_policy" "dynamodb_readonly" {
  name        = "${var.name_prefix}-EKS-DynamoDB-ReadOnly-${var.env}"
  description = "Allow read access to DynamoDB for IRSA in EKS-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ],
        Resource = aws_dynamodb_table.product_catalog_table.arn
      }
    ]
  })
}

resource "aws_iam_role" "irsa_role" {
  name = "${var.name_prefix}-irsa-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.this.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:app:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.dynamodb_readonly.arn
}
