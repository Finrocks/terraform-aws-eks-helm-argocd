module "argocd" {
  source = "../../"

  eks_cluster_id = var.eks_cluster_id

  name      = "argocd"
  namespace = "rlw"
}
