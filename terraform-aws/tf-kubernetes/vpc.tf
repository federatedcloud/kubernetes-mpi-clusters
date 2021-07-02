## Create VPC network, subnetworks
resource "aws_vpc" "main" {                
  cidr_block = "10.0.0.0/24"              
  tags = {                                
    Name = "tf-kubernetes"                
  }                                       
}                                         
                                          
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "region-name"
    values = [ var.region ]
  }
}

resource "aws_subnet" "main" {
  count = 2

  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 1, count.index)

  tags = {                                
    Name = "tf-kubernetes-subnet"         
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }                                       
}
