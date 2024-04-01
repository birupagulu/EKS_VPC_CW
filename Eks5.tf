provider "aws" {
  region = "your_region"
}

# EKS Cluster
module "eks" {
  source            = "terraform-aws-modules/eks/aws"
  cluster_name      = "your_cluster_name"
  cluster_version   = "1.21"
  subnets           = ["subnet-1", "subnet-2", "subnet-3"] # Replace with your subnet IDs
  vpc_id            = "your_vpc_id"
  worker_groups = [{
    instance_type        = "t3.medium"
    desired_capacity     = 2
    max_capacity         = 3
    min_capacity         = 1
    volume_size          = 20
    key_name             = "your_key_pair_name"
    subnets             = ["subnet-1", "subnet-2", "subnet-3"] # Replace with your subnet IDs
  }]
}

# Kubernetes Deployment
resource "kubectl_deployment" "example" {
  metadata {
    name = "example"
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "example"
      }
    }

    template {
      metadata {
        labels = {
          app = "example"
        }
      }

      spec {
        container {
          image = "your_ecr_image_uri"
          name  = "example"
        }
      }
    }
  }
}
