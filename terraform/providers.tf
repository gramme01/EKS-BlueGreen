provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}
data "aws_partition" "cur" {}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster" "this" { name = module.eks.cluster_name }
data "aws_eks_cluster_auth" "this" { name = module.eks.cluster_name }