locals {
  enabled                                     = module.this.enabled
  account_id                                  = one(data.aws_caller_identity.default[*].account_id)
  namespace                                   = module.this["namespace"]
  eks_cluster_id                              = one(data.aws_eks_cluster.cluster[*].id)
  argocd_endpoint                             = one(data.aws_eks_cluster.cluster[*].endpoint)
  eks_cluster_oidc_issuer_url                 = one(data.aws_eks_cluster.cluster[*].identity[0].oidc[0].issuer)
  application_controller_service_account_name = format("%s-application-controller", var.helm_config["name"])
  server_service_account_name                 = format("%s-server", var.helm_config["name"])
  iam_role_enabled                            = local.enabled && var.config["create_default_iam_role"]
  iam_policy_enabled                          = local.iam_role_enabled && var.config["create_default_iam_policy"]
  iam_policy_document                         = local.iam_policy_enabled ? one(data.aws_iam_policy_document.default[*].json) : var.config["iam_policy_document"]

  argocd_helm_values = templatefile("${path.module}/helm-values/argocd.yaml",
    {
      fullname_override      = var.helm_config["name"]
      sts_regional_endpoints = var.config["use_sts_regional_endpoints"]
      role_enabled           = local.iam_role_enabled
      controller_sa_name     = local.application_controller_service_account_name
      controller_role_arn    = module.argocd_application_controller_iam_role[0].service_account_role_arn
      server_sa_name         = local.server_service_account_name
      server_role_arn        = module.argocd_server_iam_role.service_account_role_arn
    }
  )
}

data "aws_caller_identity" "default" {
  count = local.enabled ? 1 : 0
}

data "aws_eks_cluster" "cluster" {
  count = local.enabled ? 1 : 0

  name = var.eks_cluster_id
}

data "utils_deep_merge_yaml" "default" {
  count = local.enabled ? 1 : 0

  input = [
    local.argocd_helm_values,
    var.helm_config["override_values"]
  ]
}

data "aws_iam_policy_document" "default" {
  count = local.iam_policy_enabled ? 1 : 0

  statement {
    effect = "Allow"

    resources = ["arn:aws:iam::${local.account_id}:role/*-argocd-deployer"]

    actions = [
      "sts:AssumeRole"
    ]
  }
}

