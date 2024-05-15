data "aws_elb_hosted_zone_id" "main" {}
resource "aws_route53_zone" "route53_domain_name" {
    # checkov:skip=CKV2_AWS_38
    # checkov:skip=CKV2_AWS_39
    name = "nt533uitjiradev.click"
    tags = {
        Environment = "dev"
    }
}