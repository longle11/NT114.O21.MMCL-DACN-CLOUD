provider "aws" {
  # region = var.aws_region
  region = "us-east-1"
}


provider "helm" {
  kubernetes {
    host     = aws_eks_cluster.eks_cluster.endpoint
    token             = data.aws_eks_cluster_auth.eks_cluster_auth.token
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  }
}

provider "kubernetes" {
  host     = aws_eks_cluster.eks_cluster.endpoint
  token             = data.aws_eks_cluster_auth.eks_cluster_auth.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
}