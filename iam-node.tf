resource "aws_iam_role" "eks_node" {

  name = "shopease-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_node" {
  for_each   = toset(local.eks_node_policies)
  policy_arn = each.value
  role       = aws_iam_role.eks_node.name
}