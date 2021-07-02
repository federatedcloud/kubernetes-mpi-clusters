## Create IAM Roles for terraform
resource "aws_iam_role" "cluster" {                                             
  name = "terraform-cluster-role"                                                     
                                                                              
  assume_role_policy = jsonencode({                                           
    Version = "2012-10-17"                                                    
    Statement = [{                                                            
      Action = "sts:AssumeRole"                                               
      Effect = "Allow"                                                        
      Principal = {                                                           
        Service = "ec2.amazonaws.com"                                         
      }
    },
    {
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]                                                                        
  })                                                                          
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

## Create cluster
resource "aws_eks_cluster" "primary" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = aws_subnet.main[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}
