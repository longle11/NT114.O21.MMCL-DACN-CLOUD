locals {
  openid_connect_provider = aws_iam_openid_connect_provider.oidc_provider.arn
  openid_connect_provider_extract_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
}

// iam role for eks cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.aws_environment}-eks-cluster-role"

  assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
    }
    POLICY
}

# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

// iam role for eks node group
resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.aws_environment}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}


# EBS IAM Policy
resource "aws_iam_policy" "ebs_iam_policy" {
  name        = "${var.aws_environment}-amazonEks-ebs-iam-policy"
  path        = "/"
  policy = data.http.iam_policy.response_body
}

# EBS IAM Role
resource "aws_iam_role" "ebs_iam_role" {
  name = "${var.aws_environment}-amazonEks-ebs-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${local.openid_connect_provider}"
        }
        Condition = {
          StringEquals = {            
            "${local.openid_connect_provider_extract_arn}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }   
      }
    ]
  })
}

# Associate EBS CSI IAM Policy to EBS CSI IAM Role
resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.ebs_iam_policy.arn 
  role       = aws_iam_role.ebs_iam_role.name
}


# checkov:skip=CKV_AWS_XX
resource "aws_iam_policy" "ingress_nginx_controller_policy" {
  # checkov:skip=CKV_AWS_289
  # checkov:skip=CKV_AWS_355
  # checkov:skip=CKV_AWS_290
  name   = "${var.aws_environment}-ingress-nginx-controller-policy"
  policy = <<POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "acm:DescribeCertificate",
            "acm:ListCertificates",
            "acm:GetCertificate"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CreateSecurityGroup",
            "ec2:CreateTags",
            "ec2:DeleteTags",
            "ec2:DeleteSecurityGroup",
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeTags",
            "ec2:DescribeVpcs",
            "ec2:ModifyInstanceAttribute",
            "ec2:ModifyNetworkInterfaceAttribute",
            "ec2:RevokeSecurityGroupIngress"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "elasticloadbalancing:AddListenerCertificates",
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:CreateRule",
            "elasticloadbalancing:CreateTargetGroup",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:DeleteRule",
            "elasticloadbalancing:DeleteTargetGroup",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:DescribeListenerCertificates",
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeLoadBalancerAttributes",
            "elasticloadbalancing:DescribeRules",
            "elasticloadbalancing:DescribeSSLPolicies",
            "elasticloadbalancing:DescribeTags",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetGroupAttributes",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:ModifyListener",
            "elasticloadbalancing:ModifyLoadBalancerAttributes",
            "elasticloadbalancing:ModifyRule",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:ModifyTargetGroupAttributes",
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:RemoveListenerCertificates",
            "elasticloadbalancing:RemoveTags",
            "elasticloadbalancing:SetIpAddressType",
            "elasticloadbalancing:SetSecurityGroups",
            "elasticloadbalancing:SetSubnets",
            "elasticloadbalancing:SetWebAcl"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "iam:CreateServiceLinkedRole",
            "iam:GetServerCertificate",
            "iam:ListServerCertificates"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "cognito-idp:DescribeUserPoolClient"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "waf-regional:GetWebACLForResource",
            "waf-regional:GetWebACL",
            "waf-regional:AssociateWebACL",
            "waf-regional:DisassociateWebACL"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "tag:GetResources",
            "tag:TagResources"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "waf:GetWebACL"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "wafv2:GetWebACL",
            "wafv2:GetWebACLForResource",
            "wafv2:AssociateWebACL",
            "wafv2:DisassociateWebACL"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "shield:DescribeProtection",
            "shield:GetSubscriptionState",
            "shield:DeleteProtection",
            "shield:CreateProtection",
            "shield:DescribeSubscription",
            "shield:ListProtections"
          ],
          "Resource": "*"
        }
      ]
    }
    POLICY
}


resource "aws_iam_role" "ingress_controller_iam_role" {
  name = "${var.aws_environment}-ingress-nginx-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${local.openid_connect_provider}"
        }
        Condition = {
          StringEquals = {
            "${local.openid_connect_provider_extract_arn}:aud": "sts.amazonaws.com",            
            "${local.openid_connect_provider_extract_arn}:sub": "system:serviceaccount:kube-system:nginx-ingress-controller" 
          }
        }        
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy" {
  policy_arn = aws_iam_policy.ingress_nginx_controller_policy.arn
  role = aws_iam_role.ingress_controller_iam_role.name
}



# Autoscaling Full Access
resource "aws_iam_role_policy_attachment" "eks-autoscaling" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.eks_nodegroup_role.name
}

# Resource: IAM Policy for Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler_iam_policy" {
  # checkov:skip=CKV_AWS_355
  # checkov:skip=CKV_AWS_290
  name        = "${var.aws_environment}-AmazonEKSClusterAutoscalerPolicy"
  path        = "/"
  description = "EKS Cluster Autoscaler Policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeInstanceTypes"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
})
}

# Resource: IAM Role for Cluster Autoscaler
## Create IAM Role and associate it with Cluster Autoscaler IAM Policy
resource "aws_iam_role" "cluster_autoscaler_iam_role" {
  name = "${var.aws_environment}-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${local.openid_connect_provider}"
        }
        Condition = {
          StringEquals = {
            "${local.openid_connect_provider_extract_arn}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }        
      },
    ]
  })

  tags = {
    tag-key = "cluster-autoscaler"
  }
}

# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.cluster_autoscaler_iam_policy.arn 
  role       = aws_iam_role.cluster_autoscaler_iam_role.name
}

# CloudWatchAgentServerPolicy for AWS CloudWatch Container Insights
resource "aws_iam_role_policy_attachment" "eks_cloudwatch_container_insights" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}



# // grafana policy and role
# resource "aws_iam_policy" "grafana_policy" {
#   name        = "grafana-policy"
#   description = "Allows Grafana to access CloudWatch and describe EC2 instances"

#   policy = <<EOF
#     {
#       "Version": "2012-10-17",
#       "Statement": [
#           {
#             "Sid": "AllowReadingMetricsFromCloudWatch",
#             "Effect": "Allow",
#             "Action": [
#                 "cloudwatch:ListMetrics",
#                 "cloudwatch:GetMetricStatistics",
#                 "cloudwatch:GetMetricData"
#             ],
#             "Resource": "*"
#           },
#           {
#             "Sid": "AllowReadingTagsInstancesRegionsFromEC2",
#             "Effect": "Allow",
#             "Action": [
#                 "ec2:DescribeTags",
#                 "ec2:DescribeInstances",
#                 "ec2:DescribeRegions"
#             ],
#             "Resource": "*"
#           }
#       ]
#     }
#     EOF
# }
# resource "aws_iam_role" "grafana_role" {
#   name = "grafana-role"

#   assume_role_policy = <<EOF
#     {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Effect": "Allow",
#           "Principal": {
#             "Service": "ec2.amazonaws.com"
#           },
#           "Action": "sts:AssumeRole"
#         }
#       ]
#     }
#     EOF
# }

# resource "aws_iam_role_policy_attachment" "grafana_policy_attachment" {
#   role       = aws_iam_role.grafana_role.name
#   policy_arn = aws_iam_policy.grafana_policy.arn
# }
