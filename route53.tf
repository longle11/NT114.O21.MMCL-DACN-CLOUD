data "aws_elb_hosted_zone_id" "main" {}
# data "kubernetes_service_v1" "ingress_controller" {
#     depends_on = [ helm_release.nginx-ingress-controller ]
#     metadata {
#         name = "nginx-ingress-controller"
#         namespace = "kube-system"
#     }
# }

data "kubernetes_service_v1" "ingress_controller" {
    depends_on = [ helm_release.kong-ingress-controller ]
    metadata {
        name = "kong-proxy"
        namespace = "kong"
    }
}



resource "aws_route53_zone" "route53_domain_name" {
    # checkov:skip=CKV2_AWS_38
    # checkov:skip=CKV2_AWS_39
    name = "nt533uitjiradev.click"
    tags = {
        Environment = "dev"
    }
}

# resource "aws_route53_record" "vault_record" {
#     zone_id = aws_route53_zone.route53_domain_name.zone_id
#     name    = "www.nt533uitjiradev.click"
#     type    = "A"

#     alias {
#         name                   = data.kubernetes_service_v1.ingress_controller.status[0].load_balancer[0].ingress[0].hostname
#         zone_id                = aws_route53_zone.route53_domain_name.zone_id
#         evaluate_target_health = true
#     }

#     depends_on = [ helm_release.nginx-ingress-controller ]
# }