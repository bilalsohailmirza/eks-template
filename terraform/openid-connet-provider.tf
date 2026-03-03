# Previosuly the EBS CSI driver did not support Pod Identities, but now it does, so we can create an IAM role for the driver and associate it with the service account used by the driver. This allows the driver to assume the role and access AWS resources securely.
# Following is the OIDC provider configuration for the EKS cluster, which is required for using IAM roles for service accounts (IRSA) with the EBS CSI driver.

data "tls_certificate" "eks" {
    # extract crtificate information from the cluster and use it to create the OIDC provider 
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}