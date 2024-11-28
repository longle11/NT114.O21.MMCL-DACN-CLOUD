# EBS CSI IAM Policy

data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

# Create ebs csi driver helm provider
data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = aws_eks_cluster.eks_cluster.id
}

// EBS CSI Driver using helm
resource "helm_release" "ebs_csi_driver" {
  depends_on = [ aws_eks_node_group.eks_nodegroup_private, aws_iam_role.ebs_iam_role]
  name       = "${var.aws_environment}-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"

  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    type  = "string"
    value = "${aws_iam_role.ebs_iam_role.arn}"
  }
}