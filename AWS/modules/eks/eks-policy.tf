resource "aws_iam_role" "eks-cluster-iam-role" {
  name = "${var.project-name}-eks-${var.infra_env}-cluster-iam-role"
assume_role_policy =<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow"
      
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-cluster-iam-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-iam-role.name
}