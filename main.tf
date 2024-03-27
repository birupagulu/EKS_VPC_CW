resource "aws_iam_role" "eks_service_role" {
  name = "eks-service-role"
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
  role       = aws_iam_role.eks_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_policy_attachment" {
  role       = aws_iam_role.eks_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

module "eks_cluster" {
  source             = "terraform-aws-modules/eks/aws"
  cluster_name       = "my-cluster"
  cluster_version    = "1.21"
  subnets            = ["subnet-abc123", "subnet-def456"] // Your subnets here
  vpc_id             = "vpc-123456"
  manage_aws_auth    = true
  worker_groups = [{
    instance_type = "t2.medium"
    asg_max_size  = 3
    asg_min_size  = 1
  }]
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "my-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name      = "my-app-container"
      image     = "your-image-url"
      cpu       = 256
      memory    = 512
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
