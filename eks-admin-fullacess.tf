//create new user for this group
resource "aws_iam_user" "eksadmin_user" {
  #checkov:skip=CKV_AWS_273
  name          = "eksadmin"
  path          = "/"
  force_destroy = true
  tags = {
    Name = "eksadmin"
  }
}

//create iam group resource
resource "aws_iam_group" "eks_admin_group" {
  name = "eksAdmins"
  path = "/"
}


//create group for containing users
resource "aws_iam_group_membership" "eksadmins_group" {
  name = "eksadmin_group_members"

  users = [
    aws_iam_user.eksadmin_user.name
  ]

  group = aws_iam_group.eks_admin_group.name
}

resource "aws_iam_role" "eks_admin_role" {
  name = "eks-admin-role"
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
    name = "eks-admin-full-access-policy"
    policy = jsonencode(
      {
        Version : "2012-10-17",
        Statement : [
          {
            Effect : "Allow",
            Action : [
              "eks:*",
              "sts:AssumeRole"
            ],
            Resource : "*"
          }
        ]
      }
    )
  }

  tags = {
    Name = "eks-admin-full-access-role"
  }
}

//create iam group resources policy
resource "aws_iam_group_policy" "iam_group_admin_assume_role_policy" {
  name  = "eksAdmins-group-policy"
  group = aws_iam_group.eks_admin_group.name


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Sid      = "AllowAssumeOrganizationAccountRole"
        Resource = "${aws_iam_role.eks_admin_role.arn}"
      },
    ]
  })
}

