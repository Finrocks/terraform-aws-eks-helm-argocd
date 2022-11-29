#variable "eks_cluster_id" {
#  type        = string
#  description = "EKS cluster ID"
#}

#####todo: fix postrender variable


variable "config" {
  type = object({
    cluster_name     = string
    create_iam_role    = optional(bool, true)
    additional_iam_policy_document        = optional(list(string), [])
#    additional_iam_policy_document        = optional(list(string), [data.aws_iam_policy_document.zalupka.json])
    use_sts_regional_endpoints = optional(bool, false)
  })

  default = {
    cluster_name = null
    create_iam_role = true
    additional_iam_policy_document = []
    use_sts_regional_endpoints = false
  }

  description = <<-DOC
    cluster_name"
      The name of the EKS cluster to install.
    create_iam_role:
      Defines whether to create default IAM role and attach it to argocd application controller and server.
    additional_iam_policy_document:
      List of policy ARNs which will be additional attached to created IAM role.
    use_sts_regional_endpoints:
      Whether to create use STS regional endpoints.
  DOC
}

variable "argocd_config" {
  type = object({
#    eks_cluster_id                 = string
#    argocd_url                     = string
    create_additional_project      = optional(bool, false)
    create_additional_cluster      = optional(bool, false)
    argocd_additional_project_name = optional(string)
    argocd_additional_cluster_name = optional(string)
  })

  description = <<-DOC
    create_additional_project:
      Define whatever create additional project or not.
    create_additional_cluster:
      Define whatever create additional cluster or not.
    argocd_additional_project:
      Name of the project, requires `create_additional_project_name = true` .
    argocd_additional_cluster:
      Name of the cluster, requires `create_additional_project_name = true`
  DOC
}

variable "helm_config" {
  type = object({
    name                       = optional(string, "argocd")
    namespace                  = optional(string, "argo")
    repository                 = optional(string, "https://argoproj.github.io/argo-helm")
    chart                      = optional(string, "argo-cd")
    version                    = optional(string, "5.15.0")
    max_history                = optional(number, 10)
    create_namespace           = optional(bool, true)
    dependency_update          = optional(bool, true)
    reuse_values               = optional(bool, false)
    reset_values               = optional(bool, false)
    override_values            = optional(string)
    wait                       = optional(bool, true)
    timeout                    = optional(number, 300)
    atomic                     = optional(bool, true)
    cleanup_on_fail            = optional(bool, false)
    disable_crd_hooks          = optional(bool, false)
    disable_openapi_validation = optional(bool, false)
    disable_webhooks           = optional(bool, false)
    force_update               = optional(bool, false)
    description                = optional(string, null)
    lint                       = optional(bool, false)
    repository_key_file        = optional(string, null)
    repository_cert_file       = optional(string, null)
    repository_ca_file         = optional(string, null)
    repository_username        = optional(string, null)
    repository_password        = optional(string, null)
    verify                     = optional(bool, false)
    recreate_pods              = optional(bool, false)
    devel                      = optional(string, null)
    keyring                    = optional(string, "/.gnupg/pubring.gpg")
    skip_crds                  = optional(bool, false)
    render_subchart_notes      = optional(bool, true)
    wait_for_jobs              = optional(bool, false)
    replace                    = optional(bool, false)
    #    postrender                 = optional(object({
    #      binary_path              = optional(string, null)
    #      args                     = optional(list(string), [null])
    #      }))
  })

  description = <<-DOC
    All input from [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release#argument-reference) resources.
  DOC
}

data "aws_iam_policy_document" "zalupka" {
  statement {
    sid    = "ArgoCDOwn"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = ["arn:aws:kms:eu-central-1:529407427714:key/12e31715-87ef-4fd1-83bb-3ded7af1565a"]
  }
}
