# resource "helm_release" "nginx-ingress-controller" {
#   depends_on = [ aws_iam_role.ingress_controller_iam_role]
#   name       = "nginx-ingress-controller"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "nginx-ingress-controller"
#   namespace = "kube-system"

#   set {
#     name  = "service.type"
#     value = "LoadBalancer"
#   }
# }

resource "kubernetes_namespace" "kong_ns" {
  metadata {
    name = "kong"
  }
}
resource "helm_release" "kong-ingress-controller" {
  depends_on = [
    aws_iam_role.ingress_controller_iam_role,
    kubernetes_namespace.kong_ns
  ]
  name       = "kong"
  repository = "https://charts.konghq.com"
  chart      = "kong"
  namespace  = "kong"

  create_namespace = false
  cleanup_on_fail  = true
  timeout          = "1500"

  values = [
    file("file/valueKong.yml")
  ]
}
