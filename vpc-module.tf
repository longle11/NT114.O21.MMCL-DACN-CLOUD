module "vpc" {
  # source = "terraform-aws-modules/vpc/aws"
  # version = "5.0.0"
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=26c38a66f12e7c6c93b6a2ba127ad68981a48671"

  name = "${var.aws_environment}-${var.vpc_name}"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway

  //cho phep khoi tao ip public trong public subnets
  map_public_ip_on_launch = true


  tags = {
    Environment = var.aws_environment
  }

  public_subnet_tags = {
    Type = "Public Subnets"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }


  private_subnet_tags = {
    Type = "Private Subnets"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}