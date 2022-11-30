module "label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = one(module.this[*].context)
}

module "parameter_store_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  #name = module.this.name
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
  context     = one(module.argocd_additional_label[*].context)
}

module "argocd_role_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  environment = var.environment
  tenant      = var.tenant
  context     = one(module.label[*].context)
}

module "argocd_additional_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  tenant      = var.tenant
  context     = one(module.this[*].context)
}

#module "argocd_tenant_label" {
#  source  = "cloudposse/label/null"
#  version = "0.25.0"
#
#  tenant      = var.tenant
#  context     = module.this.context
#}