output "cluster_name" { value = module.eks.cluster_name }
output "grafana_lb" { value = try(helm_release.monitoring.status, null) }
