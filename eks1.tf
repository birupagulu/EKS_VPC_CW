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
 
 
resource "aws_iam_role" "AWSServiceRoleForECS" {
  name = "AWSServiceRoleForECS"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
 
resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  role       = aws_iam_role.AWSServiceRoleForECS.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}
 
resource "aws_iam_role_policy_attachment" "eks_worker_policy_attachment" {
  role       = aws_iam_role.AWSServiceRoleForECS.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  #policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}
 
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}
 
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
 
 
module "eks_cluster" {
  source             = "terraform-aws-modules/eks/aws"
  cluster_name       = "gideons"
  cluster_version    = "1.24"
  subnet_ids         = ["subnet-0e6fd3a0ac5d9a751","subnet-0f9fa849f86e615b4"] // Your subnets here
  vpc_id             = "vpc-00516f4152e660c22"
}
 
resource "aws_ecs_task_definition" "app_task" {
  family                   = "my-app-task"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
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
