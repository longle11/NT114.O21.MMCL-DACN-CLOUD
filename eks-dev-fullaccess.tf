//create new user for this group
resource "aws_iam_user" "eks_dev_user" {
    #checkov:skip=CKV_AWS_273
    name = "eksdev"
    path = "/"
    force_destroy = true
    tags = {
        Name = "eksdev"
    }
}

//create group for containing users
resource "aws_iam_group_membership" "eksdev_group" {
    name = "eksdev_group_members"

    users = [
        aws_iam_user.eks_dev_user.name
    ]

    group = aws_iam_group.eks_dev_group.name
}

resource "aws_iam_role" "eks_dev_role" {
    name = "eks-dev-role"
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
        name = "eks-dev-fullaccess-policy"
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
        Name = "eks-dev-role"
    }
}


//create iam group resource
resource "aws_iam_group" "eks_dev_group" {
    name = "eksDev"
    path = "/"
}

//create iam group resources policy
resource "aws_iam_group_policy" "iam_group_dev_assume_role_policy" {
    name  = "eksdev-group-policy"
    group = aws_iam_group.eks_dev_group.name


    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                "sts:AssumeRole",
                ]
                Effect   = "Allow"
                Sid = "AllowAssumeOrganizationAccountRole"
                Resource = "${aws_iam_role.eks_dev_role.arn}"
            },
        ]
    })
}

//create kubernetes cluster role and cluster role binding resources
resource "kubernetes_cluster_role" "eks_dev_cluster_role" {
    #checkov:skip=CKV_K8S_49
    metadata {
        name = "eks-dev-cluster-role"
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

resource "kubernetes_cluster_role_binding" "eks_dev_cluster_role_binding" {
    metadata {
        name = "eks-dev-cluster-role-binding"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = kubernetes_cluster_role.eks_dev_cluster_role.metadata[0].name
    }
    subject {
        kind      = "Group"
        name      = "eks-dev-group"
        api_group = "rbac.authorization.k8s.io"
    }
}

# Resource: k8s namespace
resource "kubernetes_namespace" "k8s_dev" {
  metadata {
    name = "dev"
  }
}

//create role and role binding resources
resource "kubernetes_role" "eksdev_role" {
    depends_on = [ kubernetes_namespace.k8s_dev ]
  metadata {
    name = "eksdev-role"
    namespace = "dev"
  }

  rule {
    api_groups     = ["", "extensions", "apps"]
    resources      = ["*"]
    verbs          = ["*"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
  }
}
resource "kubernetes_role_binding" "eksdev_role_binding" {
  metadata {
    name      = "eksdev-rolebinding"
    namespace = "dev"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.eksdev_role.metadata[0].name 
  }
  subject {
    kind      = "Group"
    name      = "eks-dev-group"
    api_group = "rbac.authorization.k8s.io"
  }
}