resource "aws_eks_cluster" "main" {

  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  version = "1.33"

  vpc_config {

    subnet_ids = [
      aws_subnet.public_az1.id,
      aws_subnet.public_az2.id
    ]

    endpoint_private_access = false
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = local.common_tags
}