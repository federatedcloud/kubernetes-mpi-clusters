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
  ingress {
    cidr_blocks = ["10.0.0.0/16"]
    from_port = 53
    to_port = 53
    protocol = "udp"
    description = "dns"
  }
  ingress {
    cidr_blocks = ["10.0.0.0/16"]
    from_port = 1025
    to_port = 65535
    protocol = "udp"
    description = "dns"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "terraform-eks-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.main.version}-v*"]
  }
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

resource "tls_private_key" "nodes" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated" {
  key_name    = "${var.cluster_name}-key"
  public_key  = tls_private_key.nodes.public_key_openssh
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
  node-userdata-worker = <<USERDATAWORKER
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --kubelet-extra-args '--node-labels=role=worker' \
                      --apiserver-endpoint '${aws_eks_cluster.main.endpoint}' \
                      --b64-cluster-ca '${aws_eks_cluster.main.certificate_authority.0.data}' \
                      '${var.cluster_name}'
USERDATAWORKER
  node-userdata-launcher = <<USERDATALAUNCHER
#!/bin/bash
set -o xtrace                                                              
/etc/eks/bootstrap.sh --kubelet-extra-args '--node-labels=role=launcher' \
                      --apiserver-endpoint '${aws_eks_cluster.main.endpoint}' \
                      --b64-cluster-ca '${aws_eks_cluster.main.certificate_authority.0.data}' \
                      '${var.cluster_name}'
USERDATALAUNCHER
}

resource "aws_launch_configuration" "workers" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.node.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = var.worker_instance_type
  key_name                    = aws_key_pair.generated.key_name
  name_prefix                 = "terraform-eks-worker"
  security_groups             = [aws_security_group.node.id]
  user_data_base64            = base64encode(local.node-userdata-worker)

  root_block_device {
    volume_size = 100
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "workers" {
  desired_capacity     = var.num_workers
  launch_configuration = aws_launch_configuration.workers.id
  max_size             = var.num_workers
  min_size             = var.num_workers
  name                 = "terraform-eks-worker"
  vpc_zone_identifier  = [aws_subnet.main.0.id]

  tag {
    key                 = "Name"
    value               = "terraform-eks-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "launcher" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.node.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = var.launcher_instance_type
  key_name                    = aws_key_pair.generated.key_name
  name_prefix                 = "terraform-eks"
  security_groups             = [aws_security_group.node.id]
  user_data_base64            = base64encode(local.node-userdata-launcher)

  root_block_device {
    volume_size = 50
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "launcher" {
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.launcher.id
  max_size             = 1
  min_size             = 1
  name                 = "terraform-eks-launcher"
  vpc_zone_identifier  = [aws_subnet.main.0.id]

  tag {
    key                 = "Name"
    value               = "terraform-eks-launcher"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
