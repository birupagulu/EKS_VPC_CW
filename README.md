# EKS_VPC_CW
   59  eksctl create cluster --name gideon-cluster --region ap-southeast-1 --fargate
   60  aws eks update-kubeconfig  --name gideon-cluster --region ap-southeast-1
   61  eksctl create fargateprofile     --cluster gideon-cluster     --region ap-southeast-1     --name alb-sample-app     --namespace game-2048
   62  kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/examples/2048/2048_full.yaml
   63  kubectl get pods -n game-2048
   64  kubectl get pods -n game-2048 -w
   65  kubectl get pods -n game-2048
   66  kubectl get svc -n game-2048
   67  kubectl get ingress -n game-2048
   68  eksctl utils associate-iam-oidc-provider --cluster gideon-cluster --approve
   69  aws configure set region ap-southeast-1
   70  eksctl utils associate-iam-oidc-provider --cluster gideon-cluster --approve
   71  curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
   72  aws iam create-policy     --policy-name AWSLoadBalancerControllerIAMPolicy     --policy-document file://iam_policy.json
   73  aws iam create-policy     --policy-name AWSLoadBalancerControllerIAMPolicy     --policy-document file://iam_policy.json
   74  eksctl create iamserviceaccount   --cluster=gideon-cluster   --namespace=kube-system   --name=aws-load-balancer-controller   --role-name AmazonEKSLoadBalancerControllerRole   --attach-policy-arn=arn:aws:iam::573327415341:policy/AWSLoadBalancerControllerIAMPolicy   --approve
   80  helm version
   81  helm repo add eks https://aws.github.io/eks-charts
   82  helm repo update eks
   83    helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=gideon-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=ap-southeast-1 --set vpcId=vpc-0a2c3a1d70449b41a
   86  kubectl get deployment -n kube-system aws-load-balancer-controller
   87  kubectl get deployment -n kube-system aws-load-balancer-controller
   88  kubectl get deploy -n kube-system
   89  kubectl get pods -n kube-system
   90  kubectl get ingress -n game-2048
