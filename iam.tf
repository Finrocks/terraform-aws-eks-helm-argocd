data "aws_iam_policy_document" "argocd" {
  count = local.iam_role_enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    resources = ["arn:aws:iam::${local.account_id}:role/*-argocd-deployer"]
    sid = "ArgocdDeployer"
  }
}

data "aws_iam_policy_document" "kms" {
  count = local.iam_role_enabled && var.argocd_config["setup_admin_password"] ? 1 : 0

  statement {
    actions = ["kms:Decrypt"]
    effect = "Allow"
    resources = [one(module.argocd_kms_key[*].key_arn)]
    sid = "ArgocdParameterDecryptor"
  }
}

#    principals {
#      type        = "Federated"
##      identifiers = ["arn:aws:iam::${var.account_id}:saml-provider/${var.provider_name}", "cognito-identity.amazonaws.com"]
#      identifiers = [local.eks_cluster_oidc_issuer_url]
#    }

data "aws_iam_policy_document" "assumer" {
  count = local.iam_role_enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root", "arn:aws:iam::${local.account_id}:assumed-role/dev-pixtab-argocd-server"]
    }
  }
}

data "aws_iam_policy_document" "merge" {
  count = local.iam_role_enabled ? 1 : 0

  override_policy_documents = [
    one(data.aws_iam_policy_document.argocd[*].json),
    one(data.aws_iam_policy_document.assumer[*].json)
#    length(data.aws_iam_policy_document.kms[*].json) > 0 ? one(data.aws_iam_policy_document.kms[*].json) : ""
  ]
}

module "argocd_server_iam_role" {
  count                       = local.iam_role_enabled ? 1 : 0
  source                      = "rallyware/eks-iam-role/aws"
  version                     = "0.1.2"

  aws_iam_policy_document     = one(data.aws_iam_policy_document.merge[*].json)
  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url
  service_account_name        = local.server_service_account_name
  service_account_namespace   = var.helm_config["namespace"]

  enabled                     = local.iam_role_enabled
  context                     = one(module.argocd_role_label[*].context)
}

module "argocd_application_controller_iam_role" {
  count                       = local.iam_role_enabled ? 1 : 0
  source                      = "rallyware/eks-iam-role/aws"
  version                     = "0.1.2"

  aws_iam_policy_document     = one(data.aws_iam_policy_document.merge[*].json)
  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url
  service_account_name        = local.application_controller_service_account_name
  service_account_namespace   = var.helm_config["namespace"]

  enabled                     = local.iam_role_enabled
  context                     = one(module.argocd_role_label[*].context)
}

resource "aws_iam_role_policy_attachment" "existing_policies_to_argocd_role" {
  count      = local.iam_role_enabled ? length(var.config["additional_iam_policy_document"]) : 0
  policy_arn = local.additional_iam_policy_document[count.index]
  role       = join("", module.argocd_server_iam_role.*.service_account_role_name)
}