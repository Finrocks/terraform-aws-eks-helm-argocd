terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }

    argocd = {
      source  = "oboukili/argocd"
      version = "4.1.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2"
    }

    utils = {
      source  = "cloudposse/utils"
      version = ">= 0.14.0"
    }

    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

provider "argocd" {
  server_addr                 = "argocd-server:80"
  username                    = "admin"
  password                    = one(random_password.argocd_password[*].result)
  insecure                    = true
  port_forward                = true
  port_forward_with_namespace = var.helm_config["namespace"]

  kubernetes {
    host                   = one( data.aws_eks_cluster.cluster[*].endpoint)
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_id]
      command     = "aws"
    }
  }
}
