module "argocd_kms_key" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  description             = format("KMS key for Argocd on %s", local.eks_cluster_id)
  deletion_window_in_days = 10
  enable_key_rotation     = true
  alias                   = format("alias/%s/argocd-key", local.eks_cluster_id)

  name    = "argocd"
  context = module.argocd_kms_label[0].context
}

module "argocd_server_iam_role" {
  source = "cloudposse/eks-iam-role/aws"
  version = "1.1.0"

  attributes  = ["argocd"]

  aws_iam_policy_document = local.iam_policy_document
  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url
  service_account_name        = local.server_service_account_name
  service_account_namespace   = var.helm_config["namespace"]

  enabled = local.iam_role_enabled
  context             = module.argocd_label.context
}

#module "argocd_server_iam_role" {
#  source  = "rallyware/eks-iam-role/aws"
#  version = "0.1.2"
#
#  aws_iam_policy_document     = local.iam_policy_document
#  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url
#  service_account_name        = local.server_service_account_name
#  service_account_namespace   = var.helm_config["namespace"]
#
#  enabled = true
##  enabled = local.iam_role_enabled
#  context = module.this.context
#}

module "argocd_application_controller_iam_role" {
  source  = "rallyware/eks-iam-role/aws"
  version = "0.1.2"

  aws_iam_policy_document     = local.iam_policy_document
  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url
  service_account_name        = local.application_controller_service_account_name
  service_account_namespace   = var.helm_config["namespace"]

  enabled = false
#  enabled = local.iam_role_enabled
#  context = module.this.context
}

####todo: fix postrender variable
resource "helm_release" "argocd" {
  count = local.enabled ? 1 : 0

  name                       = var.helm_config["name"]
  repository                 = var.helm_config["repository"]
  chart                      = var.helm_config["chart"]
  version                    = var.helm_config["version"]
  namespace                  = var.helm_config["namespace"]
  max_history                = var.helm_config["max_history"]
  create_namespace           = var.helm_config["create_namespace"]
  dependency_update          = var.helm_config["dependency_update"]
  reuse_values               = var.helm_config["reuse_values"]
  reset_values               = var.helm_config["reset_values"]
  recreate_pods              = var.helm_config["recreate_pods"]
  wait                       = var.helm_config["wait"]
  devel                      = var.helm_config["devel"]
  timeout                    = var.helm_config["timeout"]
  atomic                     = var.helm_config["atomic"]
  cleanup_on_fail            = var.helm_config["cleanup_on_fail"]
  disable_crd_hooks          = var.helm_config["disable_crd_hooks"]
  disable_openapi_validation = var.helm_config["disable_openapi_validation"]
  disable_webhooks           = var.helm_config["disable_webhooks"]
  force_update               = var.helm_config["force_update"]
  description                = var.helm_config["description"]
  lint                       = var.helm_config["lint"]
  repository_key_file        = var.helm_config["repository_key_file"]
  repository_cert_file       = var.helm_config["repository_cert_file"]
  repository_ca_file         = var.helm_config["repository_ca_file"]
  repository_username        = var.helm_config["repository_username"]
  repository_password        = var.helm_config["repository_password"]
  verify                     = var.helm_config["verify"]
  keyring                    = var.helm_config["keyring"]
  skip_crds                  = var.helm_config["skip_crds"]
  render_subchart_notes      = var.helm_config["render_subchart_notes"]
  wait_for_jobs              = var.helm_config["wait_for_jobs"]
  replace                    = var.helm_config["replace"]
  #  postrender                  {
  #    binary_path              = var.helm_config.postrender["binary_path"]
  #    args                     = var.helm_config.postrender["args"]
  #  }

  values = [one(data.utils_deep_merge_yaml.default[*].output)]
}
