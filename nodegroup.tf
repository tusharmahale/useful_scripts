resource "aws_iam_role" "private-ng-range" {
  name = "eks-node-group-private-ng-range"

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

resource "aws_iam_role_policy_attachment" "private-ng-range-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.private-ng-range.name
}

resource "aws_iam_role_policy_attachment" "private-ng-range-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.private-ng-range.name
}

resource "aws_iam_role_policy_attachment" "private-ng-range-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.private-ng-range.name
}

resource "aws_eks_node_group" "private-ng-range" {
  cluster_name    = "private-cluster"
  node_group_name = "private-ng-range"
  node_role_arn   = aws_iam_role.private-ng-range.arn
  subnet_ids      = ["subnet-0ed67dc8a955f1cd0", "subnet-04b08658441bcffeb"]

  scaling_config {
    desired_size = 4
    max_size     = 6
    min_size     = 4
  }

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.private-ng-range-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.private-ng-range-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.private-ng-range-AmazonEC2ContainerRegistryReadOnly,
  ]

}
