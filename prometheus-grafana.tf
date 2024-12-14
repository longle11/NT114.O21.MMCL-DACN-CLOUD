resource "helm_release" "prometheus1" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  values = [
    file("file/valuePrometheus.yaml")
  ]
  timeout = 2000
  cleanup_on_fail = true
}
