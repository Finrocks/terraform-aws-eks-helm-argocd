terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.45.0"
    }

    argocd = {
      source  = "oboukili/argocd"
      version = "4.2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }

    utils = {
      source  = "cloudposse/utils"
      version = "1.6.0"
    }

    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
  }
}



