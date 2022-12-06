locals {
  enabled                                     = module.this.enabled
  account_id                                  = one(data.aws_caller_identity.default[*].account_id)
  eks_cluster_id                              = one(data.aws_eks_cluster.cluster[*].id)
#  argocd_endpoint                             = one(data.aws_eks_cluster.cluster[*].endpoint)
  eks_cluster_oidc_issuer_url                 = one(data.aws_eks_cluster.cluster[*].identity[0].oidc[0].issuer)
  application_controller_service_account_name = format("%s-application-controller", var.helm_config["name"])
  server_service_account_name                 = format("%s-server", var.helm_config["name"])
  iam_role_enabled                            = local.enabled && var.config["create_iam_role"]

  argocd_helm_values = templatefile("${path.module}/helm-values/argocd.yaml",
    {
      fullname_override      = var.helm_config["name"]
      sts_regional_endpoints = var.config["use_sts_regional_endpoints"]
      role_enabled           = local.iam_role_enabled
      setup_admin_password   = var.argocd_config["setup_admin_password"]
      controller_sa_name     = local.application_controller_service_account_name
      controller_role_arn    = local.iam_role_enabled == true ? one(module.argocd_application_controller_iam_role[*].service_account_role_arn) : try(one(module.argocd_application_controller_iam_role[*].service_account_role_arn), "qqq")
      server_sa_name         = local.server_service_account_name
      server_role_arn        = local.iam_role_enabled == true ? try(one(module.argocd_server_iam_role[*].service_account_role_arn), "qwe") : "qwee"
      argocd_url             = var.argocd_config["argocd_url"]
      admin_password         = local.enabled && var.argocd_config["setup_admin_password"] ? one(data.aws_ssm_parameter.encrypted_password[*].value) : null
    }
  )
}

data "aws_caller_identity" "default" {
  count = local.enabled ? 1 : 0
}

data "aws_eks_cluster" "cluster" {
  count = local.enabled ? 1 : 0

  name = var.config["eks_cluster_id"]
}

data "utils_deep_merge_yaml" "default" {
  count = local.enabled ? 1 : 0

  input = [
    local.argocd_helm_values,
    sensitive(var.helm_config["override_values"])
  ]
}
