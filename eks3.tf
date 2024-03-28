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

data "aws_vpc" "existing_vpc" {
  id = "vpc-0d870d7c497bbc736" # Replace with your existing VPC ID
}

data "aws_subnet" "subnet1" {
  id = "subnet-0628c7ce75048a5b5" # Replace with your existing subnet ID
}

data "aws_subnet" "subnet2" {
  id = "subnet-03c6c0adeffcfe90f" # Replace with your existing subnet ID
}

data "aws_security_group" "existing_security_group" {
  id = "sg-00e240ac37a7b1b18" # Replace with your existing security group ID
}
# Define existing IAM role for EKS cluster creation
data "aws_iam_role" "eks_cluster_role" {
  name = "AWSServiceRoleForAmazonEKS"
}

# Define existing IAM role for ECS task execution
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_eks_cluster" "my_cluster" {
  name     = "my-cluster"
  role_arn = "arn:aws:iam::573327415341:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS" # Replace with your existing EKS role ARN

  vpc_config {
    subnet_ids         = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id]
    security_group_ids = [data.aws_security_group.existing_security_group.id]
  }
}
 
resource "aws_ecs_task_definition" "app_task" {
  family                   = "my-app-task"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
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
  alarm_actions       = [aws_eks_cluster.my_cluster.arn]
  }
