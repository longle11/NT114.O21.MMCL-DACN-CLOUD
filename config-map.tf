data "aws_caller_identity" "current" {}
locals {
    configmap_roles = [
        {
            rolearn = "${aws_iam_role.eks_nodegroup_role.arn}"
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:bootstrappers", "system:nodes"]
        },
        {
            rolearn  = "${aws_iam_role.eks_admin_role.arn}"
            username = "eks-admin"
            groups   = ["system:masters"]
        },
        {
            rolearn = "${aws_iam_role.eks_readonly_role.arn}"
            username = "eks-readonly"
            groups   = ["${kubernetes_cluster_role_binding_v1.eks_readonly_cluster_role_binding.subject[0].name}"]
        },
        {
            rolearn  = "${aws_iam_role.eks_dev_role.arn}"
            username = "eks-dev" 
            groups   = [ "${kubernetes_role_binding_v1.eksdev_role_binding.subject[0].name}" ]
        }
    ]
} 
resource "kubernetes_config_map_v1" "aws-auth" {
    depends_on = [ 
        aws_eks_cluster.eks_cluster, 
        kubernetes_cluster_role_binding_v1.eks_dev_cluster_role_binding,
        kubernetes_cluster_role_binding_v1.eks_readonly_cluster_role_binding,
        kubernetes_role_binding_v1.eksdev_role_binding
    ]
    metadata {
        name = "aws-auth"
        namespace = "kube-system"
    }

    data = {
        mapRoles = yamlencode(local.configmap_roles)
    }
}