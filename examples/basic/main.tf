<<<<<<< HEAD
module "argocd" {
  source = "../../"

  eks_cluster_id = var.eks_cluster_id

  name      = "argocd"
  namespace = "rlw"
=======
module "aweasome_module" {
  source    = "../../"
  name      = "aweasome"
  stage     = "production"
  namespace = "babebort"
>>>>>>> c4d88a1 (Initial commit)
}
