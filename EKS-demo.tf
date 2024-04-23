variable "eks_cluster_name" {
  type    = string
  description = "EKS Cluster Name"
}

variable "namespace" {
  type    = string
  description = "Namespace"
}

variable "subnet1" {
  type    = string
  default = "/NET/GIO_OS/vpc-main/PrivSubnet1"
}

variable "subnet2" {
  type    = string
  default = "/NET/GIO_OS/vpc-main/PrivSubnet2"
}

variable "vpc_id" {
  type    = string
  default = "/NET/GIO_OS/vpc-main/VPC"
}

resource "aws_security_group" "eks_security_group" {
  name        = "EksSecurityGroup"
  description = "EKS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.0.0.0/8"]
    description = "Flow for dev tests"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "EksClusterRole"
  description        = "Role for EKS"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
  ]
}

resource "aws_iam_role" "eks_fargate_pod_execution_role" {
  name               = "EksFargatePodExecutionRole"
  description        = "Role for EKS Fargate Pod Execution"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy",
  ]
}

resource "aws_eks_cluster" "eks_cluster" {
  name       = var.eks_cluster_name
  role_arn   = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = [var.subnet1, var.subnet2]
    security_group_ids = [aws_security_group.eks_security_group.id]
  }
}

resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name         = var.eks_cluster_name
  fargate_profile_name = "${var.eks_cluster_name}Profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn

  selector {
    namespace = var.namespace
  }

  selector {
    namespace = "kube-system"
  }

  selector {
    namespace = "default"
  }

  subnet_ids = [var.subnet1, var.subnet2]
}
