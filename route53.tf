data "aws_elb_hosted_zone_id" "main" {}
# data "kubernetes_service_v1" "ingress_controller" {
#     depends_on = [ helm_release.nginx-ingress-controller ]
#     metadata {
#         name = "nginx-ingress-controller"
#         namespace = "kube-system"
#     }
# }

data "kubernetes_service_v1" "proxy_kong_ingress_controller" {
    depends_on = [ helm_release.kong-ingress-controller ]
    metadata {
        name = "kong-kong-proxy"
        namespace = "kong"
    }
}

data "kubernetes_service_v1" "admin_kong_ingress_controller" {
    depends_on = [ helm_release.kong-ingress-controller ]
    metadata {
        name = "kong-kong-admin"
        namespace = "kong"
    }
}

data "kubernetes_service_v1" "manager_kong_ingress_controller" {
    depends_on = [ helm_release.kong-ingress-controller ]
    metadata {
        name = "kong-kong-manager"
        namespace = "kong"
    }
}

data "aws_elb_hosted_zone_id" "elb_hosted_zone" {
    region = var.aws_region
}

resource "aws_route53_zone" "route53_domain_name" {
    # checkov:skip=CKV2_AWS_38
    # checkov:skip=CKV2_AWS_39
    name = var.domain_name
    tags = {
        Environment = "dev"
    }
}

resource "aws_route53_record" "kong-proxy" {
    zone_id = aws_route53_zone.route53_domain_name.zone_id
    name    = "www.${var.domain_name}"
    type    = "A"

    alias {
        name                   = data.kubernetes_service_v1.proxy_kong_ingress_controller.status[0].load_balancer[0].ingress[0].hostname
        zone_id                = data.aws_elb_hosted_zone_id.elb_hosted_zone.id //lookup id here https://docs.aws.amazon.com/general/latest/gr/elb.html
        evaluate_target_health = true
    }

    depends_on = [ helm_release.kong-ingress-controller ]
}

resource "aws_route53_record" "kong-admin" {
    zone_id = aws_route53_zone.route53_domain_name.zone_id
    name    = "admin-kong.${var.domain_name}"
    type    = "A"

    alias {
        name                   = data.kubernetes_service_v1.admin_kong_ingress_controller.status[0].load_balancer[0].ingress[0].hostname
        zone_id                = data.aws_elb_hosted_zone_id.elb_hosted_zone.id //lookup id here https://docs.aws.amazon.com/general/latest/gr/elb.html
        evaluate_target_health = true
    }

    depends_on = [ helm_release.kong-ingress-controller ]
}

resource "aws_route53_record" "kong-manager" {
    zone_id = aws_route53_zone.route53_domain_name.zone_id
    name    = "manager-kong.${var.domain_name}"
    type    = "A"

    alias {
        name                   = data.kubernetes_service_v1.manager_kong_ingress_controller.status[0].load_balancer[0].ingress[0].hostname
        zone_id                = data.aws_elb_hosted_zone_id.elb_hosted_zone.id //lookup id here https://docs.aws.amazon.com/general/latest/gr/elb.html
        evaluate_target_health = true
    }

    depends_on = [ helm_release.kong-ingress-controller ]
}