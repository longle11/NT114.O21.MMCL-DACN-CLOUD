# Load balancer controller iam policy download form aws-load-balancer-controller
data "http" "lbc_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
  request_headers = {
    Accept = "application/json"
  }
}


# Install AWS Load Balancer Controller using HELM
resource "helm_release" "loadbalancer_controller" {
  name = "${var.aws_environment}-loadbalancer-controller"

  depends_on = [ aws_iam_role.lbc_iam_role ]
  namespace = "kube-system"
  repository = "https://aws.github.io/eks-charts"   //download helm chart
  chart      = "aws-load-balancer-controller"

  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.lbc_iam_role.arn}"
  }

  set {
    name = "vpcId"
    value = "${module.vpc.vpc_id}"
  }

  set {
    name  = "region"
    value = "${var.aws_region}"
  }    
  set {
    name  = "clusterName"
    value = "${aws_eks_cluster.eks_cluster.id}"
  } 
}