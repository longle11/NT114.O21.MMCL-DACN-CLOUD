// eks cluster represents eks control plane
// when eks cluster is created. we are provisioning the control plane for kubernetes env
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.eks_cluster_name}"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = module.vpc.public_subnets
    endpoint_private_access = var.eks_endpoint_private_access   //Configuration alllows eks api interacts with private subnet
    endpoint_public_access = var.eks_endpoint_public_access //Configuration alllows eks api interacts with public subnet
    public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.eks_service_ipv4_cidr   //specify network subnets used for providing ips for pods and services,...
  }

  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]

   tags = {
    Name = "Eks-cluster"
  }
}

# Use this data source to lookup information about the current AWS partition in which Terraform is working such as "amazonaws.com"
data "aws_partition" "current" {}

data "tls_certificate" "authentication" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# AWS IAM Open ID Connect Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
  thumbprint_list = [data.tls_certificate.authentication.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.authentication.url
}


// eks nodegroup is using for managing pods,...
resource "aws_eks_node_group" "eks_nodegroup_public" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.aws_environment}-eks-nodegroup-public"

  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = module.vpc.public_subnets

  ami_type = "AL2_x86_64"
  instance_types = [var.aws_instance_type]
  capacity_type = "ON_DEMAND"
  disk_size = 20
  

  remote_access {
    ec2_ssh_key = var.aws_key_pair
  }

  scaling_config {
    desired_size = 1
    min_size     = 1    
    max_size     = 2
  }

  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1    
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

   depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ] 

  tags = {
    Name = "Public-Node-Group"
  }
}

# resource "aws_eks_node_group" "eks_nodegroup_private" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name
#   node_group_name = "${var.aws_environment}-eks-nodegroup-private"

#   node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
#   subnet_ids      = module.vpc.private_subnets

#   ami_type = "AL2_x86_64"
#   instance_types = [var.aws_instance_type]
#   capacity_type = "ON_DEMAND"
#   disk_size = 20
  

#   remote_access {
#     ec2_ssh_key = var.aws_key_pair
#   }

#   scaling_config {
#     desired_size = 2
#     min_size     = 1    
#     max_size     = 2
#   }

#   # Desired max percentage of unavailable worker nodes during node group update.
#   update_config {
#     max_unavailable = 1    
#     #max_unavailable_percentage = 50    # ANY ONE TO USE
#   }

#    depends_on = [
#     aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
#   ] 

#   tags = {
#     Name = "Private-Node-Group"
#   }
# }