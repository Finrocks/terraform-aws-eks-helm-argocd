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

data "aws_iam_policy_document" "this" {
  count            = local.enabled ? 1 : 0
  statement {
    sid    = "ArgoCDOwn"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [module.argocd_kms_key[0].key_arn]
  }
}

module "argocd_server_iam_role" {
  source = "cloudposse/eks-iam-role/aws"
  version = "1.1.0"

  attributes  = ["argocd"]

  aws_iam_policy_document =   [data.aws_iam_policy_document.default[*].json, data.aws_iam_policy_document.this[*].json]    #local.iam_policy_document
  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url
  service_account_name        = local.server_service_account_name
  service_account_namespace   = var.helm_config["namespace"]

  enabled             = local.iam_role_enabled
  context             = module.argocd_label.context
}