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

resource "kubectl_manifest" "ebs_sc" {
  depends_on = [aws_eks_cluster.eks_cluster, aws_eks_node_group.eks_nodegroup_private, kubernetes_namespace.kong_ns]

  yaml_body = <<YAML
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: ebs-sc
    provisioner: ebs.csi.aws.com
    volumeBindingMode: WaitForFirstConsumer
    allowVolumeExpansion: true
    reclaimPolicy: Retain
YAML
}


resource "helm_release" "kong-ingress-controller" {
  depends_on = [
    aws_iam_role.ingress_controller_iam_role,
    kubernetes_namespace.kong_ns,
    kubectl_manifest.ebs_sc
  ]
  name       = "kong"
  repository = "https://charts.konghq.com"
  version    = "2.41.1"
  chart      = "kong"
  namespace  = "kong1"

  create_namespace = false
  cleanup_on_fail  = true
  timeout          = "1500"

  values = [
    file("file/valueKong1.yml")
  ]
  # set {
  #   name  = "env.database"
  #   value = "postgres"
  # }

  # set {
  #   name  = "env.pg_host"
  #   value = "postgresql-svc.kong.svc.cluster.local:5432"
  # }

  # set {
  #   name  = "env.pg_user"
  #   value = "kong"
  # }

  # set {
  #   name  = "env.pg_password"
  #   value = "kong"
  # }

  # set {
  #   name  = "env.pg_database"
  #   value = "kong"
  # }

  # set {
  #   name  = "env.pg_ssl"
  #   value = "off"
  # }

  # set {
  #   name  = "env.pg_password"
  #   value = "off"
  # }

  # # Kích hoạt Proxy với LoadBalancer
  # set {
  #   name  = "proxy.enabled"
  #   value = "true"
  # }

  # set {
  #   name  = "proxy.type"
  #   value = "LoadBalancer"
  # }

  # set {
  #   name  = "proxy.http.servicePort"
  #   value = "8000"
  # }

  # set {
  #   name  = "proxy.tls.servicePort"
  #   value = "8443"
  # }

  # # Kích hoạt Manager với LoadBalancer
  # set {
  #   name  = "manager.enabled"
  #   value = "true"
  # }

  # set {
  #   name  = "manager.type"
  #   value = "LoadBalancer"
  # }

  # set {
  #   name  = "manager.http.servicePort"
  #   value = "8002"
  # }

  # # Kích hoạt Admin API với LoadBalancer
  # set {
  #   name  = "admin.enabled"
  #   value = "true"
  # }

  # set {
  #   name  = "admin.type"
  #   value = "LoadBalancer"
  # }

  # set {
  #   name  = "admin.http.servicePort"
  #   value = "8001"
  # }

  # set {
  #   name  = "admin.tls.servicePort"
  #   value = "8444"
  # }
}
