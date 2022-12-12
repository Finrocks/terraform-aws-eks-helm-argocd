provider "argocd" {
  server_addr                 = "argocd-server:80"
  username                    = "admin"
  password                    = one(random_password.argocd_password[*].result)
  insecure                    = true
  port_forward                = true
  port_forward_with_namespace = var.helm_config["namespace"]

  kubernetes {
    host                   = local.argocd_endpoint #one(data.aws_eks_cluster.cluster[*].endpoint)
    cluster_ca_certificate = try(base64decode(one(data.aws_eks_cluster.cluster[*].certificate_authority[0].data)), null)
    token                  = one(data.aws_eks_cluster_auth.cluster[*].token)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_id]
      command     = "aws"
    }
  }
}
