data "aws_iam_policy_document" "ebs_csi_driver" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}



resource "aws_iam_role" "ebs_csi_driver" {
  name               = "${aws_eks_cluster.eks.name}-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}


# Optional: if its a requirement to encrypt the EBS drives
resource "aws_iam_policy" "ebs_csi_driver_encryption" {
  name = "${aws_eks_cluster.eks.name}-ebs-csi-driver-encryption"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })
}

# Optional: if its a requirement to encrypt the EBS drives
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_encryption" {
  policy_arn = aws_iam_policy.ebs_csi_driver_encryption.arn
  role       = aws_iam_role.ebs_csi_driver.name
}


resource "aws_eks_pod_identity_association" "ebs_csi_driver" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi_driver.arn
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.31.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  depends_on = [aws_eks_node_group.general]
}

# use aws eks describe-addon-versions --region <region-name> --addon-name aws-ebs-csi-driver to find the latest version of the addon, and update the version in the code above accordingly


# Instead of using old OIDC method we can now use Pod Identities for the EBS CSI driver, which is more secure and easier to manage. The code below creates an IAM role for the EBS CSI driver, attaches the necessary policies, and associates it with the service account used by the driver. This allows the driver to assume the role and access AWS resources securely without needing to manage long-lived credentials.

# resource "aws_iam_role" "ebs_csi_driver" {
#   name = "${aws_eks_cluster.eks.name}-ebs-csi-role"

#   # The Trust Policy now points to pods.eks.amazonaws.com
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "pods.eks.amazonaws.com"
#         }
#         Action = [
#           "sts:AssumeRole",
#           "sts:TagSession"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_pause" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.ebs_csi_driver.name
# }

# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name                = aws_eks_cluster.eks.name
#   addon_name                  = "aws-ebs-csi-driver"
#   addon_version               = "v1.30.0-eksbuild.1" # Use a version that supports Pod Identity

#   pod_identity_association {
#     role_arn        = aws_iam_role.ebs_csi_driver.arn
#     service_account = "ebs-csi-controller-sa"
#   }
# }