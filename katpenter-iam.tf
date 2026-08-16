##############################################################
# KARPENTER IAM
#
# Purpose:
# Terraform creates the AWS IAM resources required by
# Karpenter Controller to provision and terminate EC2 instances.
#
# Flow:
#
# Karpenter Pod
#       │
#       ▼
# ServiceAccount (IRSA)
#       │
#       ▼
# IAM Role
#       │
#       ▼
# IAM Policy
#       │
#       ▼
# AWS EC2 APIs
#
##############################################################

##############################################################
# IAM POLICY
#
# Policy = WHAT Karpenter can do.
#
# Role = WHO Karpenter is.
##############################################################

resource "aws_iam_policy" "karpenter" {

  # Better than hardcoding
  # Example:
  # shopease-dev-karpenter-policy
  name = "${var.cluster_name}-karpenter-policy"

  description = "IAM Policy for Karpenter Controller"

  ############################################################
  # jsonencode()
  #
  # Terraform converts this HCL object into JSON
  # before sending it to AWS.
  ############################################################

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      ########################################################
      # Statement 1
      #
      # DISCOVERY
      #
      # Purpose:
      # Read AWS infrastructure.
      #
      # Karpenter first discovers:
      #
      # • Subnets
      # • Security Groups
      # • Instance Types
      # • Availability Zones
      #
      # These are READ ONLY APIs.
      ########################################################

      {
        Sid = "Discovery"

        Effect = "Allow"

        Action = [

          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeImages",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeSpotPriceHistory"

        ]

        # Describe APIs generally use *
        Resource = "*"
      },

      ########################################################
      # Statement 2
      #
      # PROVISIONING
      #
      # Purpose:
      # Create EC2 Instances.
      #
      ########################################################

      {
        Sid = "Provision"

        Effect = "Allow"

        Action = [

          "ec2:RunInstances",
          "ec2:CreateFleet",
          # Apply tags while launching
          "ec2:CreateTags"

        ]

        Resource = "*"
      },

      ########################################################
      # Statement 3
      #
      # CLEANUP
      #
      # Purpose:
      #
      # Remove unused EC2 instances.
      #
      ########################################################

      {
        Sid = "Cleanup"

        Effect = "Allow"

        Action = [

          "ec2:TerminateInstances"

        ]

        Resource = "*"
      },
      {
        Sid = "Pricing"

        Effect = "Allow"

        Action = [

          "pricing:GetProducts"

        ]

        Resource = "*"
      },

      ########################################################
      # Statement 4
      #
      # IAM
      #
      # Purpose:
      #
      # Allow Karpenter to attach the Worker Node IAM Role
      # while launching EC2.
      #
      # Without this:
      #
      # RunInstances
      #      ↓
      # AccessDenied
      # iam:PassRole
      #
      ########################################################

      {
        Sid = "PassNodeRole"

        Effect = "Allow"

        Action = [

          "iam:PassRole"

        ]

        ######################################################
        # Better security practice:
        #
        # Instead of "*",
        # specify only the Worker Node Role ARN.
        ######################################################

        Resource = aws_iam_role.eks_node.arn

      },
      {
        Sid = "LaunchTemplateManagement"

        Effect = "Allow"

        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:DeleteLaunchTemplateVersions"
        ]

        Resource = "*"
      },
      {
        Sid = "InstanceProfileManagement"

        Effect = "Allow"

        Action = [
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:ListInstanceProfiles",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:UntagInstanceProfile",
          "iam:GetRole"
        ]

        Resource = "*"
      },
      {
        Sid = "EKSDiscovery"

        Effect = "Allow"

        Action = [
          "eks:DescribeCluster"
        ]

        Resource = "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
      }

    ]

  })

}

resource "aws_iam_service_linked_role" "ec2_spot" {
  aws_service_name = "spot.amazonaws.com"

  description = "Service-linked role for EC2 Spot Instances"
}
##############################################################
# IAM ROLE
#
# Identity of Karpenter.
#
# Policy answers:
# WHAT can it do?
#
# Role answers:
# WHO is making the request?
##############################################################

resource "aws_iam_role" "karpenter" {

  name = "${var.cluster_name}-karpenter-role"

  ############################################################
  # Trust Policy
  #
  # IRSA uses OIDC.
  #
  # Only the Karpenter ServiceAccount
  # should be able to assume this role.
  ############################################################

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:karpenter"
          }
        }
      }
    ]
  })
}

##############################################################
# Attach Policy to Role
##############################################################

resource "aws_iam_role_policy_attachment" "karpenter" {

  role = aws_iam_role.karpenter.name

  policy_arn = aws_iam_policy.karpenter.arn

}

##############################################################
# OUTPUT
##############################################################

output "karpenter_role_arn" {

  description = "IAM Role ARN used by IRSA"

  value = aws_iam_role.karpenter.arn

}