module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  #environment   = local.environment
  #name      = var.project_name
}

#module "argocd_label" {
#  source  = "cloudposse/label/null"
#  version = "0.25.0"
#
#  environment   = local.environment
#  tenant      = var.project_name
#
#  label_order = ["environment", "tenant", "stage", "name", "attributes"]
#  #label_value_case = "title"
#  #delimiter = ""
#}

module "label_vpc" {
  source        = "cloudposse/label/null"
  version       = "0.25.0"

  attributes    = ["vpc"]
  #environment   = local.environment
  #name          = var.project_name
}

module "eks_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  #name    = module.eks.eks_cluster_id
  context = module.label.context
}

module "argocd_kms_label" {
  source              = "cloudposse/label/null"
  version             = "0.25.0"

  delimiter           = "/"
  label_order         = ["namespace", "environment", "stage", "tenant", "name", "attributes"]
  attributes          = ["kms-key"]
  context             = module.argocd_additional_label.context
}

module "argocd_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  #name    = var.project_name
  context = module.argocd_additional_label.context
}

module "argocd_additional_label" {
  source         = "cloudposse/label/null"
  version        = "0.25.0"

  environment    = var.environment
  tenant         = var.tenant
  context        = module.this.context
}