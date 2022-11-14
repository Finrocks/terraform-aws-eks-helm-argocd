locals {
  enabled                                     = module.this.enabled
  account_id                                  = one(data.aws_caller_identity.default[*].account_id)
  eks_cluster_oidc_issuer_url                 = one(data.aws_eks_cluster.default[*].identity[0].oidc[0].issuer)
  application_controller_service_account_name = format("%s-application-controller", var.config["name"])
  server_service_account_name                 = format("%s-server", var.config["name"])
  iam_role_enabled                            = local.enabled && var.config["create_default_iam_role"]
  iam_policy_enabled                          = local.iam_role_enabled && var.config["create_default_iam_policy"]
  iam_policy_document                         = local.iam_policy_enabled ? one(data.aws_iam_policy_document.default[*].json) : var.config["iam_policy_document"]

  argocd_helm_values = templatefile("${path.module}/helm-values/argocd.yaml",
    {
      fullname_override      = var.config["name"]
      sts_regional_endpoints = var.config["use_sts_regional_endpoints"]
      role_enabled           = local.iam_role_enabled
      controller_sa_name     = local.application_controller_service_account_name
      controller_role_arn    = module.application_controller_eks_iam_role.service_account_role_arn
      server_sa_name         = local.server_service_account_name
      server_role_arn        = module.server_eks_iam_role.service_account_role_arn
    }
  )
}

data "aws_caller_identity" "default" {
  count = module.this.enabled ? 1 : 0
}

data "aws_eks_cluster" "default" {
  count = module.this.enabled ? 1 : 0

  name = var.eks_cluster_id
}

data "utils_deep_merge_yaml" "default" {
  count = local.enabled ? 1 : 0

  input = [
    local.argocd_helm_values,
    var.config["override_values"]
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

module "server_eks_iam_role" {
  source  = "rallyware/eks-iam-role/aws"
  version = "0.1.2"

  aws_iam_policy_document     = local.iam_policy_document
  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url
  service_account_name        = local.server_service_account_name
  service_account_namespace   = var.config["namespace"]

  enabled = local.iam_role_enabled
  context = module.this.context
}

module "application_controller_eks_iam_role" {
  source  = "rallyware/eks-iam-role/aws"
  version = "0.1.2"

  aws_iam_policy_document     = local.iam_policy_document
  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url
  service_account_name        = local.application_controller_service_account_name
  service_account_namespace   = var.config["namespace"]

  enabled = local.iam_role_enabled
  context = module.this.context
}

resource "helm_release" "default" {
  count = local.enabled ? 1 : 0

  name              = var.config["name"]
  repository        = var.config["repository"]
  chart             = var.config["chart"]
  version           = var.config["version"]
  namespace         = var.config["namespace"]
  max_history       = var.config["max_history"]
  create_namespace  = var.config["create_namespace"]
  dependency_update = var.config["dependency_update"]
  reuse_values      = var.config["reuse_values"]
  wait              = var.config["wait"]
  timeout           = var.config["timeout"]
  values            = [one(data.utils_deep_merge_yaml.default[*].output)]
}
