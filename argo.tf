resource "helm_release" "argocd" {
  name = "argocd"
  depends_on = [aws_eks_node_group.eks_nodegroup_private]           
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [file("file/argocd.yaml")]
}