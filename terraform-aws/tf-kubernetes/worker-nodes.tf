## Create IAM role for worker nodes
resource "aws_iam_role" "nodes" {
  name = "terraform-node-role"

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

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

## Create worker node group
resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.primary.name
  node_group_name = "workers"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = aws_subnet.main[*].id

  scaling_config {
    desired_size = var.num_nodes
    max_size     = var.num_nodes
    min_size     = var.num_nodes
  }

  capacity_type  = "ON_DEMAND"
  disk_size      = 25
  ## Comparable to n2-standard-4
  instance_types = ["m5n.xlarge"]
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}
