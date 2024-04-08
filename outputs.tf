# EC2  bastion outputs
## ec2_bastion_public_instance_ids
output "ec2_bastion_public_instance_ids" {
  description = "List of IDs of instances"
  value       = module.ec2_bastion_public.id
}

## ec2_bastion_public_ip
output "ec2_bastion_eip" {
  description = "Elastic IP associated to the Bastion Host"
  value       = aws_eip.bastion_elastic_ip.public_ip
}


# Eks outputs
# Output: AWS IAM Open ID Connect Provider
output "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "AWS IAM Open ID Connect Provider extract from ARN"
   value = local.aws_iam_oidc_connect_provider_extract_from_arn
}

/*
# Sample Outputs for Reference
aws_iam_openid_connect_provider_arn = "arn:aws:iam::180789647333:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/A9DED4A4FA341C2A5D985A260650F232"
aws_iam_openid_connect_provider_extract_from_arn = "oidc.eks.us-east-1.amazonaws.com/id/A9DED4A4FA341C2A5D985A260650F232"
*/

output "eks_cluster_id" {
  description = "The name/id of the EKS cluster."
  value = aws_eks_cluster.eks_cluster.id
}
output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = aws_eks_cluster.eks_cluster.arn
}
output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}
output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.eks_cluster.endpoint
}
output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.eks_cluster_role.arn
}
output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

# EKS Node Group Outputs - Public
output "node_group_public_id" {
  description = "Public Node Group ID"
  value       = aws_eks_node_group.eks_nodegroup_public.id
}

output "node_group_public_arn" {
  description = "Public Node Group ARN"
  value       = aws_eks_node_group.eks_nodegroup_public.arn
}

# EKS Node Group Outputs - Private

# output "node_group_private_id" {
#   description = "Node Group 1 ID"
#   value       = aws_eks_node_group.eks_nodegroup_private.id
# }

# output "node_group_private_arn" {
#   description = "Private Node Group ARN"
#   value       = aws_eks_node_group.eks_nodegroup_private.arn
# }


# EBS Output
# output "ebs_csi_iam_role_arn" {
#   description = "EBS CSI IAM Role ARN"
#   value = aws_iam_role.ebs_csi_iam_role.arn
# }