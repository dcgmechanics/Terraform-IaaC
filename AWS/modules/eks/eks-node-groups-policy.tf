resource "aws_iam_role" "eks-nodes-general-role" {
  name = "${var.project-name}-eks-${var.infra_env}-nodes-general-role"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-policy-general" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-nodes-general-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cni-policy-general" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-nodes-general-role.name
}

resource "aws_iam_role_policy_attachment" "eks-ec2-container-registry-read-only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-nodes-general-role.name
}

resource "aws_eks_node_group" "eks-nodes-general" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${var.project-name}-eks-${var.infra_env}-nodes"
  node_role_arn   = aws_iam_role.eks-nodes-general-role.arn

  subnet_ids = [
    var.subnet_ids[2], 
    var.subnet_ids[3]
  ]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  ami_type             = "AL2_x86_64"
  capacity_type        = "ON_DEMAND"
  disk_size            = 50
  force_update_version = false
  instance_types       = ["t3a.medium"]

  labels = {
    role = "eks-nodes"
  }

  version = var.k8s-ver #K8s Version

  # depends_on = [
  #   aws_iam_role_policy_attachment.eks-worker-node-policy-general,
  #   aws_iam_role_policy_attachment.eks-cni-policy-general,
  #   aws_iam_role_policy_attachment.eks-ec2-container-registry-read-only
  # ]

  depends_on = [
    aws_iam_role.eks-nodes-general-role
  ]
}