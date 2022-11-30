module "label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context
}

module "parameter_store_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  label_order = ["namespace", "environment", "stage", "tenant", "name", "attributes"]
  attributes  = ["argocd-password"]
  context     = one(module.argocd_additional_label[*].context)
}

module "argocd_kms_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  label_order = ["namespace", "environment", "stage", "tenant", "name", "attributes"]
  attributes  = ["argocd-kms-key"]

 # context     = module.argocd_additional_label.context
  context     = one(module.argocd_additional_label[*].context)
}

module "argocd_role_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  environment = var.environment
  tenant      = module.this.tenant  #??
  context     = one(module.label[*].context)
}

module "argocd_additional_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  tenant      = module.this.tenant  #??
  context     = one(module.label[*].context)
}
