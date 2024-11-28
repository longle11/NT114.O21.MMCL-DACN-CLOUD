resource "kubernetes_namespace" "argocd_ns" {
  metadata {
    name = var.argo_namespace
  }
}
resource "helm_release" "argocd" {
  depends_on = [ aws_eks_node_group.eks_nodegroup_private, kubernetes_namespace.argocd_ns ]
  name = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = var.argo_namespace
  version    = "5.36.7"
  create_namespace = false
  cleanup_on_fail = true
  timeout    = "1500"
  values = [file("file/argocd.yaml")]
}


resource "kubernetes_namespace" "argocd_rollout_ns" {
  metadata {
    name = "argocd-rollout"
  }
}
resource "helm_release" "argocd_rollout" {
  depends_on = [ aws_eks_node_group.eks_nodegroup_private, kubernetes_namespace.argocd_rollout_ns ]
  name = "my-release"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  namespace        = "argocd-rollout"
  version    = "2.38.0"
  create_namespace = false
  cleanup_on_fail = true
  timeout    = "1500"
  values = [file("file/valuesArgocdRollout.yml")]
}