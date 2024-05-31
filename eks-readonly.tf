//create new user for this group
resource "aws_iam_user" "eks_readonly_user" {
    #checkov:skip=CKV_AWS_273
    name = "eksreadonly"
    path = "/"
    force_destroy = true
    tags = {
        Name = "eksreadonly"
    }
}

//create group for containing users
resource "aws_iam_group_membership" "eksreadonly_group" {
    name = "eksreadonly_group_members"

    users = [
        aws_iam_user.eks_readonly_user.name
    ]

    group = aws_iam_group.eks_readonly_group.name
}

resource "aws_iam_role" "eks_readonly_role" {
    name = "eks-readonly-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                    AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                }
            },
        ]
    })

    inline_policy {
        name = "eks-readonly-policy"
        policy = jsonencode(
            {
                Version = "2012-10-17"
                Statement = [
                    {
                        Action   = [
                            "iam:ListRoles",
                            "ssm:GetParameter",
                            "eks:DescribeNodegroup",
                            "eks:ListNodegroups",
                            "eks:DescribeCluster",
                            "eks:ListClusters",
                            "eks:AccessKubernetesApi",
                            "eks:ListUpdates",
                            "eks:ListFargateProfiles",
                            "eks:ListIdentityProviderConfigs",
                            "eks:ListAddons",
                            "eks:DescribeAddonVersions"
                        ]
                        Effect   = "Allow"
                        Resource = "*"
                    },
                ]
            }
        )

    }

    tags = {
        Name = "eks-readonly-role"
    }
}


//create iam group resource
resource "aws_iam_group" "eks_readonly_group" {
    name = "eksReadonly"
    path = "/"
}

//create iam group resources policy
resource "aws_iam_group_policy" "iam_group_readonly_assume_role_policy" {
    name  = "eksreadonly-group-policy"
    group = aws_iam_group.eks_readonly_group.name


    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = [
                "sts:AssumeRole",
            ]
            Effect   = "Allow"
            Sid = "AllowAssumeOrganizationAccountRole"
            Resource = "${aws_iam_role.eks_readonly_role.arn}"
        },
        ]
    })
}

//create kubernetes cluster role and cluster role binding resources
resource "kubernetes_cluster_role" "eks_readonly_cluster_role" {
    #checkov:skip=CKV_K8S_49
    metadata {
        name = "eks-readonly-cluster-role"
    }

    rule {
        api_groups = [""]   //default is cors
        resources  = ["namespaces", "pods", "nodes", "events", "services"]
        verbs      = ["get", "list"]
    }
    rule {
        api_groups = ["apps"]  
        resources  = ["replicasets", "statefulsets", "deployments", "daemonsets"]
        verbs      = ["get", "list"]
    }
    rule {
        api_groups = ["batch"]  
        resources  = ["jobs"]
        verbs      = ["get", "list"]
    }
}

resource "kubernetes_cluster_role_binding" "eks_readonly_cluster_role_binding" {
    metadata {
        name = "eks-readonly-cluster-role-binding"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = kubernetes_cluster_role.eks_readonly_cluster_role.metadata.0.name
    }
    subject {
        kind      = "Group"
        name      = "eks-readonly-group"
        api_group = "rbac.authorization.k8s.io"
    }
}