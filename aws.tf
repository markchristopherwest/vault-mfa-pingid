

provider "aws" {
  # Configuration options
    region = "us-west-2"

}

data "aws_vpc" "default" {
  default = true
} 

# https://registry.terraform.io/providers/hashicorp/aws/2.43.0/docs/resources/subnet#basic-usage
resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "false"
  enable_dns_support = "true"
#   enable_classiclink = "false"
#   enable_classiclink_dns_support = "false"
  assign_generated_ipv6_cidr_block = "false"
  tags = {
    Name = "test_vpc"
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "test_cidr_1" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc_ipv4_cidr_block_association" "test_cidr_2" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  cidr_block = "10.2.0.0/16"
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc_ipv4_cidr_block_association.test_cidr_2.cidr_block, 12, 0)}"
  availability_zone = "us-west-2a"

  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc_ipv4_cidr_block_association.test_cidr_2.cidr_block, 12, 1)}"
  availability_zone = "us-west-2b"

  tags = {
    Name = "public"
  }
}



# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#basic-usage
resource "aws_eks_cluster" "example" {
  name     = "eks-${random_pet.example.id}"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = [aws_subnet.public.id, aws_subnet.private.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.example.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.example.certificate_authority[0].data
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#example-iam-role-for-eks-cluster
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = "eks-cluster-example"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.example.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.example.name
}

