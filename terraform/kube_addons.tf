# AWS Load Balancer Controller
resource "helm_release" "alb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"
  set = [
{
      name  = "clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "region"
      value = var.region
    }, 
    {
      name  = "vpcId"
      value = module.vpc.vpc_id
    }
  ]
}

# kube-prometheus-stack (Prometheus+Grafana)
resource "helm_release" "monitoring" {
  name             = "kps"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "65.5.0"

  values = [yamlencode({
    grafana = {
      adminUser     = "admin"
      adminPassword = "admin123"
      service       = { type = "LoadBalancer" }
    }
    prometheus = {
      prometheusSpec = {
        scrapeInterval = "15s"
      }
    }
  })]
}
