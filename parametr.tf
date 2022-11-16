locals {
  argocd_namespace = "argo"
  argo_sync_policy = {
    "automated" : {
      selfHeal : true
    }
    "syncOptions" = ["CreateNamespace=true", "ApplyOutOfSyncOnly=true"]
    "retry" : {
      "limit" : 5
      "backoff" : {
        "duration" : "30s"
        "factor" : 2
        "maxDuration" : "3m0s"
      }
    }
  }

  argocd_values = templatefile("./helm-values/argocd.yaml",
    {
      argocd_url = var.argocd_config["argocd_url"]
      #admin_password                  = data.aws_ssm_parameter.encrypted_password.value
      admin_password = module.argocd_parameter_store_read.values
    }
  )

}

resource "random_password" "argocd_password" {
  length           = 20
  special          = true
  override_special = "_%@$"
}

module "argocd_parameter_store" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.10.0"
  enabled = true

  parameter_write = [
    {
      name        = "/${local.eks_cluster_id}/argocd/password"
      type        = "SecureString"
      value       = random_password.argocd_password.result
      description = "A password for accessing ArgoCD installation in ${local.eks_cluster_id} EKS cluster"
    },
    {
      name        = "/${local.eks_cluster_id}/argocd/password/encrypted"
      type        = "SecureString"
      value       = bcrypt(random_password.argocd_password.result, 10)
      description = "An encrypted password for accessing ArgoCD installation in ${local.eks_cluster_id} EKS cluster"
    },
  ]

  ignore_value_changes = true
  kms_arn              = module.argocd_kms_key.alias_arn

  context = module.argocd_kms_label.context

  depends_on = [
    random_password.argocd_password
  ]

}

module "argocd_parameter_store_read" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.10.0"

  parameter_read = ["/${local.eks_cluster_id}/argocd/password/encrypted"]

  depends_on = [module.argocd_parameter_store]
  context    = module.this.context
}

data "aws_ssm_parameter" "encrypted_password" {
  name       = "/${local.eks_cluster_id}/argocd/password/encrypted"
  depends_on = [module.argocd_parameter_store]
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "ArgoCDOwn"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [module.argocd_kms_key.key_arn]
  }
}

####todo: need fix when enabled = false
module "argocd" {
  enabled = true
  source  = "git@github.com:Finrocks/terraform-aws-eks-helm-argocd.git"
  #version = "0.2.0"

  eks_cluster_id = local.eks_cluster_id

  config = {
    create_default_iam_policy = var.config["create_default_iam_policy"]
    create_default_iam_role   = var.config["create_default_iam_role"]
    #iam_policy_document = data.aws_iam_policy_document.this.json
    use_sts_regional_endpoints = var.config["use_sts_regional_endpoints"]
  }

  helm_config = {
    name              = var.helm_config["argocd"]
    namespace         = var.helm_config["namespace"]
    repository        = var.helm_config["repository"]
    chart             = var.helm_config["chart"]
    version           = var.helm_config["version"]
    max_history       = var.helm_config["max_history"]
    create_namespace  = var.helm_config["create_namespace"]
    dependency_update = var.helm_config["dependency_update"]
    wait              = var.helm_config["wait"]
    wait_for_jobs     = var.helm_config["wait_for_jobs"]
    timeout           = var.helm_config["timeout"]
    recreate_pods     = var.helm_config["recreate_pods"]
    override_values   = [one(data.utils_deep_merge_yaml.default[*].output)]
  }

  argocd_config = {
    argocd_url                     = var.argocd_config["argocd_url"]
    create_additional_project      = var.argocd_config["create_additional_project"]
    create_additional_cluster      = var.argocd_config["create_additional_cluster"]
    argocd_additional_project_name = var.argocd_config["argocd_additional_project_name"]
    argocd_additional_cluster_name = var.argocd_config["argocd_additional_cluster_name"]
  }

  context = module.argocd_label.context

  # Uncomment on first apply
  depends_on = [
    module.argocd_parameter_store, data.aws_ssm_parameter.encrypted_password, module.argocd_parameter_store_read
  ]
}

####todo: need fix when enabled = false
module "argocd_additional_cluster" {
  enabled = true
  source  = "git@github.com:Finrocks/terraform-argocd-additional-cluster.git"

  eks_cluster_id = local.eks_cluster_id
  depends_on     = [module.argocd]
}

#module "argocd_apps" {
#  enabled = true
#  source  = "rallyware/aws-eks-cluster-bootstrap/argocd"
#  version = "0.8.0"
#
#  eks_cluster_id = module.eks.eks_cluster_id
#
#  argocd_cluster_default_enabled = false
#  argocd_project_default_enabled = false
#  #argocd_iam_role_arn = module.argocd_deployer_role.arn
#
#  argocd_additional_projects = [
#    {
#      name = var.project_name
#      #description = "zapalula"
#    }
#  ]
#
#  argocd_namespace = local.argocd_namespace
#
#  app_of_apps_helm_chart = {
#    "chart": "argocd-app-of-apps"
#    "repository": "https://rallyware.github.io/terraform-argocd-aws-eks-cluster-bootstrap"
#    "version": "0.5.0"
#  }
#
#  argocd_app_config = {
#    name                       = "app-of-apps"
#    project                    = var.project_name
#    cluster_name               = module.eks.eks_cluster_id
#    wait                       = false
#    create                     = "60m"
#    update                     = "60m"
#    delete                     = "60m"
#    sync_options               = ["CreateNamespace=true", "ApplyOutOfSyncOnly=true"]
#    automated_prune            = true
#    automated_self_heal        = true
#    automated_allow_empty      = true
#    retry_limit                = 2
#    retry_backoff_duration     = "30s"
#    retry_backoff_max_duration = "1m"
#    retry_backoff_factor       = 2
#  }
#
#  argocd_app_annotations = {
#    "notifications.argoproj.io/subscribe.on-deployed.slack"     = "argocd-cluster-bootstrap"
#    "notifications.argoproj.io/subscribe.on-sync-failed.slack"  = "argocd-cluster-bootstrap"
#    "notifications.argoproj.io/subscribe.on-sync-running.slack" = "argocd-cluster-bootstrap"
#    "notifications.argoproj.io/subscribe.on-deleted.slack"      = "argocd-cluster-bootstrap"
#  }
#
#  argocd_apps = [
#    {
#      name            = "cluster-autoscaler"
#      namespace       = "kube-system"
#      chart           = "cluster-autoscaler"
#      repository      = "https://kubernetes.github.io/autoscaler"
#      version         = "9.21.0"
#      override_values = local.cluster_autoscaler_values
#      sync_wave       = -8
#      sync_policy     = {}
#      sync_options = {
#        CreateNamespace = true
#        ApplyOutOfSyncOnly = true
#        RespectIgnoreDifferences = true
#      }
##      max_history = "11"
##      retry_limit                = 22
##      retry_backoff_duration     = "33s"
##      retry_backoff_max_duration = "11m"
##      retry_backoff_factor       = 22
##      retry = {
##        limit = 2
##        backoff = {
##          duration = "5s"
##          factor = 2
##          maxDuration = "3m0s"
##        }
##      }
#
#      create_default_iam_policy = false
#      iam_policy_document = data.aws_iam_policy_document.cluster_autoscaler.json
#      ignore_differences = [
#        {
#          group             = "apps"
#          kind              = "Deployment"
#          jqPathExpressions = [".spec.replicas"]
#        }
#      ]
#    }
#  ]
#
#  name      = ""
#  label_order = ["namespace", "environment", "stage", "tenant", "name", "attributes"]
#  context = module.argocd_label.context
#  #depends_on = [module.argocd_additional_cluster]
#}