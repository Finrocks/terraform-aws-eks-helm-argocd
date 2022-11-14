variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster ID"
}

#####todo: fix postrender variable
variable "helm_config" {
  type = object({
    name                       = optional(string, "argocd")
    namespace                  = optional(string, "argo")
    repository                 = optional(string, "https://argoproj.github.io/argo-helm")
    chart                      = optional(string, "argo-cd")
    version                    = optional(string, "5.13.8")
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

variable "argocd_config" {
  type = object({
    create_additional_project          = optional(bool, false)
    create_additional_cluster          = optional(bool, false)
    argocd_additional_project_name     = optional(string)
    argocd_additional_cluster_name     = optional(string)
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

variable "config" {
  type = object({
    create_default_iam_policy  = optional(bool, true)
    create_default_iam_role    = optional(bool, true)
    iam_policy_document        = optional(string)
    use_sts_regional_endpoints = optional(bool, false)
  })


  description = <<-DOC
    create_default_iam_policy:
      Defines whether to create default IAM policy.
    create_default_iam_role:
      Defines whether to create default IAM role.
    iam_policy_document:
      Custom IAM policy which will be assigned to IAM role.
    use_sts_regional_endpoints:
      Whether to create use STS regional endpoints.
  DOC
}
