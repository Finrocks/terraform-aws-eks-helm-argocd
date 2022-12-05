## Usage
```hcl
locals {
  argocd_values = templatefile("./helm-values/argocd.yaml",
    {
      argocd_url                      = "${var.argocd_url}"
      admin_password                  = data.aws_ssm_parameter.encrypted_password.value
      github_token                    = var.argocd_github_access_token
    }
  )
}
              
    module "argocd" {
      enabled = true
      source  = "git::git@github.com:Finrocks/terraform-aws-eks-helm-argocd.git"
      #version = "0.2.0"
      eks_cluster_id = module.eks.eks_cluster_id
      config = {
        create_default_iam_policy = true
        create_default_iam_role = true
        #iam_policy_document = data.aws_iam_policy_document.this.json
        use_sts_regional_endpoints = true
      }
      helm_config = {
        name                                     = "argocd"
        namespace                                = local.argocd_namespace
        repository                               = "https://argoproj.github.io/argo-helm"
        chart                                    = "argo-cd"
        version                                  = "5.13.8"
        max_history                              = 10
        create_namespace                         = true
        dependency_update                        = true
        wait                                     = true
        wait_for_jobs                            = true
        timeout                                  = 300
        recreate_pods                            = true
        override_values                          = local.argocd_values
      }
      argocd_config = {
      }
      context = module.argocd_label.context
      # Uncomment on first apply
      depends_on = [
        time_sleep.eks_node_groups_wait
      ]
    }
```
    

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aweasome_module"></a> [aweasome\_module](#module\_aweasome\_module) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS --> 

## License
The Apache-2.0 license
