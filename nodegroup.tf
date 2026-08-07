resource "aws_eks_node_group" "main" {

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "shopease-dev-ng"

  node_role_arn = aws_iam_role.eks_node.arn

  subnet_ids = [
    aws_subnet.public_az1.id,
    aws_subnet.public_az2.id
  ]

  instance_types = [var.node_instance_type]

  ami_type = "AL2023_x86_64_STANDARD"

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node
  ]

  tags = local.common_tags
}