# module "ec2_bastion_sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "5.1.2"

#   name = "${var.aws_environment}-bastion-pb-sg"
#   description = "Security Group with ssh port open for everybody (IPv4 CIDR), egress port are all world open"
#   vpc_id = module.vpc.vpc_id
  
#   ingress_rules = ["ssh-tcp"]
#   ingress_cidr_blocks = ["0.0.0.0/0"]

#   egress_rules = ["all-all"]
#   tags = {
#     Environment = var.aws_environment
#   }
# }