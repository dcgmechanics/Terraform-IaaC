resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.eks_name}-cluster"
  role_arn = aws_iam_role.eks-cluster-iam-role.arn
  version  = var.k8s-ver

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true

  #count = length(var.subnet_ids)
  subnet_ids = [
    var.subnet_ids[0], 
    var.subnet_ids[1], 
    var.subnet_ids[2], 
    var.subnet_ids[3]
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-iam-policy
  ]
}