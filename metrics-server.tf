resource "helm_release" "metrics_server_release" {
  depends_on = [ aws_eks_node_group.eks_nodegroup_private ]
  name       = "${var.aws_environment}-metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace = "kube-system"   
}