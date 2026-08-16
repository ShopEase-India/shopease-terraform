data "aws_caller_identity" "current" {}

locals {
  oidc_provider = replace(
    aws_iam_openid_connect_provider.eks.url,
    "https://",
    ""
  )
}

data "aws_iam_policy_document" "alb_assume_role" {

  statement {

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    effect = "Allow"

    principals {

      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }

    condition {

      test = "StringEquals"

      variable = "${local.oidc_provider}:sub"

      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }

    condition {

      test = "StringEquals"

      variable = "${local.oidc_provider}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}