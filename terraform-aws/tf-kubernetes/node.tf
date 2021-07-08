resource "aws_iam_role" "node" {
  name = "terraform-eks-node"
  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_instance_profile" "node" {
  name = "terraform-eks"
  role = aws_iam_role.node.name
}
resource "aws_security_group" "node" {
  name = "terraform-eks-node"
  description = "Security group for all nodes in the cluster"
  vpc_id = aws_vpc.main.id

  ingress {
    cidr_blocks = ["128.84.0.0/16"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
    description = "cornell access" 
  }
  ingress { 
    cidr_blocks = ["10.0.0.0/16"]
    from_port = 0
    to_port = 65535 
    protocol = "tcp"
    description = "internal access"
  }
  ingress {
    cidr_blocks = ["10.0.0.0/16"]
    from_port = -1 
    to_port = -1
    protocol = "icmp"
    description = "ping"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "terraform-eks-node"
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}

#resource "aws_security_group_rule" "node-ingress-self" {
#  description              = "Allow node to communicate with each other"
#  from_port                = 0
#  protocol                 = "-1"
#  security_group_id        = aws_security_group.node.id
#  source_security_group_id = aws_security_group.node.id
#  to_port                  = 65535
#  type                     = "ingress"
#}
#
#resource "aws_security_group_rule" "node-ingress-cluster-https" {
#  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
#  from_port                = 443
#  protocol                 = "tcp"
#  security_group_id        = aws_security_group.node.id
#  source_security_group_id = aws_security_group.cluster.id
#  to_port                  = 443
#  type                     = "ingress"
#}
#
#resource "aws_security_group_rule" "node-ingress-cluster-others" {
#  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
#  from_port                = 1025
#  protocol                 = "tcp"
#  security_group_id        = aws_security_group.node.id
#  source_security_group_id = aws_security_group.cluster.id
#  to_port                  = 65535
#  type                     = "ingress"
#}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 443
  type                     = "ingress"
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.main.version}-v*"]
  }
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.main.endpoint}' --b64-cluster-ca '${aws_eks_cluster.main.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "workers" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.node.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = var.instance_type
  name_prefix                 = "terraform-eks"
  security_groups             = [aws_security_group.node.id]
  user_data_base64            = base64encode(local.node-userdata)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "workers" {
  desired_capacity     = var.num_workers
  launch_configuration = aws_launch_configuration.workers.id
  max_size             = var.num_workers
  min_size             = var.num_workers
  name                 = "terraform-eks"
  vpc_zone_identifier  = aws_subnet.main.0.id

  tag {
    key                 = "Name"
    value               = "terraform-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
