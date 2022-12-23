locals {
  enabled                                     = module.this.enabled
  account_id                                  = one(data.aws_caller_identity.default[*].account_id)
  eks_cluster_id                              = one(data.aws_eks_cluster.cluster[*].id)
  argocd_endpoint                             = one(data.aws_eks_cluster.cluster[*].endpoint)
  eks_cluster_oidc_issuer_url                 = one(data.aws_eks_cluster.cluster[*].identity[0].oidc[0].issuer)
  application_controller_service_account_name = format("%s-application-controller", var.helm_config["name"])
  server_service_account_name                 = format("%s-server", var.helm_config["name"])
  additional_iam_policy_document              = sort(var.config["additional_iam_policy_document"])
  ca_data                                     = try(base64decode(one(data.aws_eks_cluster.cluster[*].certificate_authority[0].data)), null)
  argocd_endpoint                             = one(data.aws_eks_cluster.cluster[*].endpoint)
  #short-checker
  argocd_additional_project                   = local.enabled && var.argocd_config["create_additional_project"]
  argocd_ingress_enabled                      = local.enabled && var.argocd_config["argocd_enable_ingress"]
  admin_password_enabled                      = local.enabled && var.argocd_config["setup_admin_password"]
  iam_role_enabled                            = local.enabled && var.config["create_iam_role"]

  argocd_helm_values                          = templatefile("${path.module}/helm-values/argocd.yaml",
    {
      fullname_override                       = var.helm_config["name"]
      sts_regional_endpoints                  = var.config["use_sts_regional_endpoints"]
      role_enabled                            = local.iam_role_enabled
      ingress_enabled                         = local.argocd_ingress_enabled
      admin_password_setup                    = local.admin_password_enabled
      controller_sa_name                      = local.application_controller_service_account_name
      controller_role_arn                     = local.iam_role_enabled ? one(module.argocd_application_controller_iam_role[*].service_account_role_arn) : try(one(module.argocd_application_controller_iam_role[*].service_account_role_arn), "")
      server_sa_name                          = local.server_service_account_name
      server_role_arn                         = local.iam_role_enabled ? one(module.argocd_server_iam_role[*].service_account_role_arn) : ""
      argocd_url                              = var.argocd_config["argocd_url"]
      admin_password                          = try(one(data.aws_ssm_parameter.encrypted_password[*].value), null)
    }
  )
}

data "aws_eks_cluster" "cluster" {
  count = local.enabled ? 1 : 0

  name = var.config["eks_cluster_id"]
}

data "aws_eks_cluster_auth" "cluster" {
  count = local.enabled ? 1 : 0

  name = var.config["eks_cluster_id"]
}

data "aws_caller_identity" "default" {
  count = local.enabled ? 1 : 0
}

data "utils_deep_merge_yaml" "default" {
  count = local.enabled ? 1 : 0

  input = [
    local.argocd_helm_values,
    var.helm_config["override_values"]
#    sensitive(var.helm_config["override_values"])
  ]
}

####todo: fix postrender variable
resource "helm_release" "argocd" {
  count = local.enabled ? 1 : 0

  name                       = var.helm_config["name"]
  repository                 = var.helm_config["repository"]
  chart                      = var.helm_config["chart"]
  version                    = var.helm_config["version"]
  namespace                  = var.helm_config["namespace"]
  max_history                = var.helm_config["max_history"]
  create_namespace           = var.helm_config["create_namespace"]
  dependency_update          = var.helm_config["dependency_update"]
  reuse_values               = var.helm_config["reuse_values"]
  reset_values               = var.helm_config["reset_values"]
  recreate_pods              = var.helm_config["recreate_pods"]
  wait                       = var.helm_config["wait"]
  devel                      = var.helm_config["devel"]
  timeout                    = var.helm_config["timeout"]
  atomic                     = var.helm_config["atomic"]
  cleanup_on_fail            = var.helm_config["cleanup_on_fail"]
  disable_crd_hooks          = var.helm_config["disable_crd_hooks"]
  disable_openapi_validation = var.helm_config["disable_openapi_validation"]
  disable_webhooks           = var.helm_config["disable_webhooks"]
  force_update               = var.helm_config["force_update"]
  description                = var.helm_config["description"]
  lint                       = var.helm_config["lint"]
  repository_key_file        = var.helm_config["repository_key_file"]
  repository_cert_file       = var.helm_config["repository_cert_file"]
  repository_ca_file         = var.helm_config["repository_ca_file"]
  repository_username        = var.helm_config["repository_username"]
  repository_password        = var.helm_config["repository_password"]
  verify                     = var.helm_config["verify"]
  keyring                    = var.helm_config["keyring"]
  skip_crds                  = var.helm_config["skip_crds"]
  render_subchart_notes      = var.helm_config["render_subchart_notes"]
  wait_for_jobs              = var.helm_config["wait_for_jobs"]
  replace                    = var.helm_config["replace"]
  #  postrender                  {
  #    binary_path              = var.helm_config.postrender["binary_path"]
  #    args                     = var.helm_config.postrender["args"]
  #  }

  values = [one(data.utils_deep_merge_yaml.default[*].output)]
}

resource "argocd_project" "default" {
  count = local.argocd_additional_project ? 1 : 0

  metadata {
    name      = var.argocd_config["argocd_additional_project_name"]
    namespace = var.helm_config["namespace"]
    labels    = module.this.tags
  }

  spec {
    description  = format("Bootstrap %s", local.eks_cluster_id)
    source_repos = ["*"]

    destination {
      name      = local.eks_cluster_id
      server    = local.argocd_endpoint
      namespace = "*"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "*"
    }

    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    orphaned_resources {
      warn = true
    }
  }
}


#resource "argocd_cluster" "additional_cluster" {
#  count = local.enabled ? 1 : 0
#
#  server = local.argocd_endpoint
#  name   = local.eks_cluster_id
#
#  config {
#    tls_client_config {
#      ca_data = local.ca_data
#      insecure = false
#    }
#  }
#}

####todo: need fix when enabled = false
#module "argocd_additional_cluster" {
#  enabled = true
#  source  = "git@github.com:Finrocks/terraform-argocd-additional-cluster.git"
#
#  eks_cluster_id = local.eks_cluster_id
#  depends_on     = [helm_release.argocd]
#}
