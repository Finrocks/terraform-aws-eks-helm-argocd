module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context
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


module "argocd_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.argocd_additional_label.context
}

module "argocd_additional_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  environment = var.environment
  tenant      = var.tenant
  context     = module.this.context
}
