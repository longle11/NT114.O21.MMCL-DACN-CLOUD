locals {
  openid_connect_provider = aws_iam_openid_connect_provider.oidc_provider.arn
  openid_connect_provider_extract_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
}

// iam role for eks cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.aws_environment}-eks-cluster-role"
  lifecycle {
    create_before_destroy = true
  }

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

resource "aws_iam_policy" "oidc_provider_policy" {
  
  name = "${var.aws_environment}-oidc_provider_policy"
  policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "iam:GetOpenIDConnectProvider",
            "iam:DeleteOpenIDConnectProvider",
            "iam:DeletePolicy"
          ],
          "Resource": "*"
        }
      ]
    }
EOF
}


resource "aws_iam_role_policy_attachment" "user_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.oidc_provider_policy.arn # ARN của chính sách
  depends_on = [ aws_iam_openid_connect_provider.oidc_provider ]
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
  lifecycle {
    create_before_destroy = true
  }

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
# eksctl create iamidentitymapping --cluster myekscluster --arn arn:aws:iam::767397749712:user/cloud_user --group system:masters --username cloud_user


# EBS IAM Policy
resource "aws_iam_policy" "ebs_iam_policy" {
  name        = "${var.aws_environment}-amazonEks-ebs-iam-policy"
  lifecycle {
    create_before_destroy = true
  }
  path        = "/"
  policy = data.http.iam_policy.response_body
}

# EBS IAM Role
resource "aws_iam_role" "ebs_iam_role" {
  name = "${var.aws_environment}-amazonEks-ebs-iam-role"
  lifecycle {
    create_before_destroy = true
  }

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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




# Load balancer controller
# create iam policy
resource "aws_iam_policy" "lbc_iam_policy" {
  name = "${var.aws_environment}-AwsLoadBalancerController-policy"
  path = "/"
  description = "AWS load balancer controller policy"
  policy = data.http.lbc_policy.response_body
}

# create iam role
resource "aws_iam_role" "lbc_iam_role" {
  name = "${var.aws_environment}-lbc-role"

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
            "${local.openid_connect_provider_extract_arn}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller" //name of service account which needs to attach
          }
        }        
      },
    ]
  })
}

# Associate lbc iam policy with iam role
resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy" {
  policy_arn = aws_iam_policy.lbc_iam_policy.arn
  role = aws_iam_role.lbc_iam_role.name
}