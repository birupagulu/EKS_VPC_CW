# Define provider and version
provider "aws" {
  region = var.region
}

# Define default variables
variable "cluster_name" {
  default = "my-cluster"
}
variable "region" {
  default = "your-region"
}
variable "vpc_id" {
  default = "vpc-12345678"
}
variable "subnet_ids" {
  default = ["subnet-12345678", "subnet-87654321"]
}
variable "security_group_id" {
  default = "sg-12345678"
}
variable "eks_version" {
  default = "1.21"
}
variable "fargate_profile_name" {
  default = "default"
}
variable "namespace" {
  default = "default"
}
variable "service_name" {
  default = "my-service"
}
variable "container_name" {
  default = "my-container"
}
variable "image" {
  default = "123456789012.dkr.ecr.your-region.amazonaws.com/my-image:latest"
}

# Create EKS cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks-cluster-role"
  version  = var.eks_version

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }
}

# Define Fargate profile
resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name = aws_eks_cluster.cluster.name
  fargate_profile_name = var.fargate_profile_name
  subnet_ids = var.subnet_ids
  selectors {
    namespace = var.namespace
    labels = {
      app = var.service_name
    }
  }
}

# Define the Kubernetes deployment
resource "kubernetes_deployment" "example" {
  metadata {
    name = var.service_name
    namespace = var.namespace
    labels = {
      app = var.service_name
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = var.service_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.service_name
        }
      }
      spec {
        container {
          name = var.container_name
          image = var.image
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
