resource "helm_release" "nginx-ingress-controller" {
  depends_on = [ aws_iam_role.ingress_controller_iam_role, aws_eks_node_group.eks_nodegroup_private ]
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  namespace = "kube-system"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}