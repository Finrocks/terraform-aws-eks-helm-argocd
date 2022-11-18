module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context
}

# For example, when using defaults, `module.this.context.delimiter`
# will be null, and `module.this.delimiter` will be `-` (hyphen).

module "parameter_store_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name = module.this.name
  label_order = ["namespace", "environment", "stage", "tenant", "name", "attributes"]
  attributes  = ["argocd-password"]
  context     = module.argocd_additional_label.context
}

module "argocd_kms_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  label_order = ["namespace", "environment", "stage", "tenant", "name", "attributes"]
  attributes  = ["kms-key"]
  context     = module.argocd_additional_label.context
}

module "argocd_role_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  environment = var.environment
  tenant      = var.tenant
  context     = module.label.context
}

module "argocd_additional_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  tenant      = var.tenant
  context     = module.this.context
}

#module "argocd_tenant_label" {
#  source  = "cloudposse/label/null"
#  version = "0.25.0"
#
#  tenant      = var.tenant
#  context     = module.this.context
#}