############################################################
# AWS Load Balancer Controller Service Account
############################################################

resource "kubernetes_service_account" "alb_controller" {

  metadata {

    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }

    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}