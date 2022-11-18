module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context
}

variable "ddel" {
  default = "/"
}

module "parameter_store_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes  = [format("argocd%spassword" var.ddel)]
  label_order = ["namespace", "stage", "tenant", "name", "attributes"]
  context     = module.argocd_additional_label.context
}

module "argocd_kms_label" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/label/null"
  version = "0.25.0"

  environment = var.environment
  label_order = ["namespace", "environment", "stage", "tenant", "name", "attributes"]
  attributes  = ["kms-key"]
  context     = module.argocd_additional_label.context
}

module "argocd_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  environment = var.environment
  tenant      = var.tenant
  context     = module.label.context
}

module "argocd_additional_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  #tenant      = var.tenant
  context     = module.this.context
}
