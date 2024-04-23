terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"  # Update with your desired AWS region
}

resource "aws_eks_cluster" "my_cluster" {
  name     = "eks-cluster"
  role_arn = "arn:aws:iam::573327415341:role/eks-cluster-role"  # Update with your existing IAM role for EKS

  vpc_config {
    subnet_ids         = ["subnet-00f89687349ad0664", "subnet-041da239e65a32ae2"]  # Update with your existing subnet IDs
    endpoint_private_access = true
    endpoint_public_access  = false
  }
}

resource "aws_eks_fargate_profile" "my_fargate_profile" {
  cluster_name = aws_eks_cluster.my_cluster.name
  fargate_profile_name = "fargate-eks"
  pod_execution_role_arn = "arn:aws:iam::573327415341:role/eks-pod-role"
  subnet_ids = ["subnet-00f89687349ad0664", "subnet-041da239e65a32ae2"]  # Update with your existing subnet IDs

   selector {
    namespace = "kube-system"
    }
    depends_on = [aws_eks_cluster.my_cluster]
  }
