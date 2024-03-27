terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
 
# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
}
 
module "eks_cluster" {
  source             = "terraform-aws-modules/eks/aws"
  cluster_name       = "gideons"
  cluster_version    = "1.24"
  role_arn           = arn:aws:iam::077598156737:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS //replace with existing IAM EKS role ARN
  subnet_ids         = ["subnet-0e6fd3a0ac5d9a751","subnet-0f9fa849f86e615b4"] // Your subnets here
  vpc_id             = "vpc-00516f4152e660c22"
 }
 
resource "aws_ecs_task_definition" "app_task" {
  family                   = "my-app-task"  
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "3072"
  requires_compatibilities = ["FARGATE"]
 
  container_definitions = jsonencode([
    {
      name      = "customer"
      image     = "dev-gideons-customer-img"
      cpu       = 1024
      memory    = 3072
      essential = true
    }
    // Add more container definitions as needed
  ])
}
 
resource "aws_cloudwatch_metric_alarm" "eks_cluster_cpu_alarm" {
  alarm_name          = "eks-cluster-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when CPU exceeds 80%"
  alarm_actions       = [module.eks_cluster.cluster_arn]
  }
