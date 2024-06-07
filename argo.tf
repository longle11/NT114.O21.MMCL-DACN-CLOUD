resource "kubernetes_namespace" "argocd_ns" {
  metadata {
    name = var.argo_namespace
  }
}
resource "helm_release" "argocd" {
  depends_on = [ kubernetes_namespace.argocd_ns ]
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