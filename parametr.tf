module "argocd_kms_key" {
  count = local.enabled ? 1 : 0
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  description             = format("KMS key for Argocd on %s", local.eks_cluster_id)
  deletion_window_in_days = 10
  enable_key_rotation     = true
  alias                   = format("alias/%s/argocd", local.eks_cluster_id)

  context = module.argocd_kms_label[0].context
}

resource "random_password" "argocd_password" {
  count            = local.enabled ? 1 : 0
  length           = 20
  special          = true
  override_special = "_%@$"
}

module "argocd_parameter_store" {
  count = local.enabled ? 1 : 0

  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.10.0"

  parameter_write = [
    {
      name        = "/${local.eks_cluster_id}/argocd/password"
      type        = "SecureString"
      value       = random_password.argocd_password[0].result
      description = "A password for accessing ArgoCD installation in ${local.eks_cluster_id} EKS cluster"
    },
    {
      name        = "/${local.eks_cluster_id}/argocd/password/encrypted"
      type        = "SecureString"
      value       = bcrypt(random_password.argocd_password[0].result, 10)
      description = "An encrypted password for accessing ArgoCD installation in ${local.eks_cluster_id} EKS cluster"
    },
  ]

  ignore_value_changes = true
  kms_arn              = one(module.argocd_kms_key[*].alias_arn)


  #enabled = true
  name = null
  context = one(module.parameter_store_label[*].context)
  depends_on = [random_password.argocd_password]
}

#module "argocd_parameter_store_read" {
#  count = local.enabled ? 1 : 0
#  source  = "cloudposse/ssm-parameter-store/aws"
#  version = "0.10.0"
#
#  parameter_read = ["/${local.eks_cluster_id}/argocd/password/encrypted"]
#
#  #enabled = true
#  context    = module.this.context
#
#  depends_on = [module.argocd_parameter_store]
#}

data "aws_ssm_parameter" "encrypted_password" {
  count            = local.enabled ? 1 : 0
  name             = "/${local.eks_cluster_id}/argocd/password/encrypted"
  depends_on       = [module.argocd_parameter_store]
}

####todo: need fix when enabled = false
#module "argocd_additional_cluster" {
#  enabled = true
#  source  = "git@github.com:Finrocks/terraform-argocd-additional-cluster.git"
#
#  eks_cluster_id = local.eks_cluster_id
#  depends_on     = [helm_release.argocd]
#}

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