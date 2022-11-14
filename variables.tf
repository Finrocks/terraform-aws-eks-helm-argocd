variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster ID"
}

variable "config" {
  type = object({
    name                       = optional(string, "argocd")
    namespace                  = optional(string, "argo")
    repository                 = optional(string, "https://argoproj.github.io/argo-helm")
    chart                      = optional(string, "argo-cd")
    version                    = optional(string, "3.33.3")
    override_values            = optional(string)
    max_history                = optional(number, 10)
    create_namespace           = optional(bool, true)
    dependency_update          = optional(bool, true)
    reuse_values               = optional(bool, false)
    wait                       = optional(bool, true)
    timeout                    = optional(number, 300)
    create_default_iam_policy  = optional(bool, true)
    create_default_iam_role    = optional(bool, true)
    iam_policy_document        = optional(string)
    use_sts_regional_endpoints = optional(bool, false)
  })

  default = {
    name                       = "argocd"
    namespace                  = "argo"
    repository                 = "https://argoproj.github.io/argo-helm"
    chart                      = "argo-cd"
    version                    = "3.33.3"
    max_history                = 10
    create_namespace           = true
    dependency_update          = true
    reuse_values               = false
    timeout                    = 300
    override_values            = ""
    wait                       = true
    create_default_iam_policy  = true
    create_default_iam_role    = true
    iam_policy_document        = ""
    use_sts_regional_endpoints = false
  }

  description = <<-DOC
    name:
      Release name.
    chart:
      Chart name to be installed. 
    repository:
      Repository URL where to locate the requested chart.
    version:
      Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace:
      The namespace to install the release into.
    timeout:
      Time in seconds to wait for any individual kubernetes operation.
    reuse_values:
      When upgrading, reuse the last release's values and merge in any overrides.
    dependency_update:
      Runs helm dependency update before installing the chart.
    create_namespace:
      Create the namespace if it does not yet exist.
    wait:
      Will wait until all resources are in a ready state before marking the release as successful.
    override_values:
      A helm values to override.
    create_default_iam_policy:
      Whether to create default IAM policy.
    create_default_iam_role:
      Whether to create default IAM role.
    iam_policy_document:
      Custom IAM policy which will be assigned to IAM role.
    use_sts_regional_endpoints:
      Whether to create use STS regional endpoints.
  DOC
}
