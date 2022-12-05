# Usage
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
  source  = "git::git@github.com:Finrocks/terraform-aws-eks-helm-argocd.git?ref=pre-release"

  config = {
    eks_cluster_id             = module.eks.eks_cluster_id
    create_iam_role            = true
    use_sts_regional_endpoints = true
  }

  argocd_config = {
    argocd_url = var.argocd_url #doesnt work
    setup_admin_password = true
    create_additional_project      = false
    create_additional_cluster      = false
    argocd_additional_project_name = null
    argocd_additional_cluster_name = null
    #    argocd_namespace               = local.argocd_namespace
    #    create_ingress                 = true
    #    argocd_ingress_host            = var.argocd_url
  }

  helm_config = {
    name              = "argocd"
    namespace         = local.argocd_namespace
    repository        = "https://argoproj.github.io/argo-helm"
    chart             = "argo-cd"
    version           = "5.16.1"
    max_history       = 10
    create_namespace  = true
    dependency_update = true
    wait              = true
    wait_for_jobs     = true
    timeout           = 300
    recreate_pods     = true
    ####todo: need check whatever nonsensitive doesnt work
    #override_values                          = nonsensitive(local.argocd_values)
    override_values = local.argocd_values
  }

  context = module.argocd_label.context

  # Uncomment on first apply
  depends_on = [time_sleep.eks_node_groups_wait]
}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.4.3 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_utils"></a> [utils](#provider\_utils) | >= 0.14.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd_additional_label"></a> [argocd\_additional\_label](#module\_argocd\_additional\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_argocd_application_controller_iam_role"></a> [argocd\_application\_controller\_iam\_role](#module\_argocd\_application\_controller\_iam\_role) | cloudposse/eks-iam-role/aws | 1.1.0 |
| <a name="module_argocd_kms_key"></a> [argocd\_kms\_key](#module\_argocd\_kms\_key) | cloudposse/kms-key/aws | 0.12.1 |
| <a name="module_argocd_kms_label"></a> [argocd\_kms\_label](#module\_argocd\_kms\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_argocd_parameter_store"></a> [argocd\_parameter\_store](#module\_argocd\_parameter\_store) | cloudposse/ssm-parameter-store/aws | 0.10.0 |
| <a name="module_argocd_role_label"></a> [argocd\_role\_label](#module\_argocd\_role\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_argocd_server_iam_role"></a> [argocd\_server\_iam\_role](#module\_argocd\_server\_iam\_role) | cloudposse/eks-iam-role/aws | 1.1.0 |
| <a name="module_label"></a> [label](#module\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_parameter_store_label"></a> [parameter\_store\_label](#module\_parameter\_store\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy_attachment.existing_policies_to_argocd_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [random_password.argocd_password](https://registry.terraform.io/providers/hashicorp/random/3.4.3/docs/resources/password) | resource |
| [aws_caller_identity.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.argocd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.merge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.encrypted_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [utils_deep_merge_yaml.default](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_config"></a> [argocd\_config](#input\_argocd\_config) | `argocd_url`:<br>  Argocd url for ingress<br>setup\_admin\_password<br>  Define whatever setup [configs.secret.argocdServerAdminPassword](https://artifacthub.io/packages/helm/argo/argo-cd#argo-cd-configs). Generated password take a look at [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html).<br>create\_additional\_project:<br>  Define whatever create additional project or not.<br>create\_additional\_cluster:<br>  Define whatever create additional cluster or not.<br>argocd\_additional\_project:<br>  Name of the project, requires `create_additional_project_name = true` .<br>argocd\_additional\_cluster:<br>  Name of the cluster, requires `create_additional_project_name = true` | <pre>object({<br>    argocd_url                     = string #doesnt work<br>    setup_admin_password           = optional(bool, true)<br>    create_additional_project      = optional(bool, false)<br>    create_additional_cluster      = optional(bool, false)<br>    argocd_additional_project_name = optional(string, null)<br>    argocd_additional_cluster_name = optional(string, null)<br>  })</pre> | n/a | yes |
| <a name="input_config"></a> [config](#input\_config) | eks\_cluster\_id<br>  The name of the EKS cluster to install.<br>create\_iam\_role:<br>  Defines whether to create default IAM role and attach it to argocd application controller and server.<br>additional\_iam\_policy\_document:<br>  List of policy ARNs which will be additional attached to created IAM role.<br>use\_sts\_regional\_endpoints:<br>  Whether to create use STS regional endpoints. | <pre>object({<br>    eks_cluster_id     = string<br>    create_iam_role    = optional(bool, true)<br>    additional_iam_policy_document        = optional(list(string), [])<br>    use_sts_regional_endpoints = optional(bool, false)<br>  })</pre> | n/a | yes |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | All input from [helm\_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release#argument-reference) resources. | <pre>object({<br>    name                       = optional(string, "argocd")<br>    namespace                  = optional(string, "argo")<br>    repository                 = optional(string, "https://argoproj.github.io/argo-helm")<br>    chart                      = optional(string, "argo-cd")<br>    version                    = optional(string, "5.16.1")<br>    max_history                = optional(number, 10)<br>    create_namespace           = optional(bool, true)<br>    dependency_update          = optional(bool, true)<br>    reuse_values               = optional(bool, false)<br>    reset_values               = optional(bool, false)<br>    override_values            = optional(string)<br>    wait                       = optional(bool, true)<br>    timeout                    = optional(number, 300)<br>    atomic                     = optional(bool, true)<br>    cleanup_on_fail            = optional(bool, false)<br>    disable_crd_hooks          = optional(bool, false)<br>    disable_openapi_validation = optional(bool, false)<br>    disable_webhooks           = optional(bool, false)<br>    force_update               = optional(bool, false)<br>    description                = optional(string, null)<br>    lint                       = optional(bool, false)<br>    repository_key_file        = optional(string, null)<br>    repository_cert_file       = optional(string, null)<br>    repository_ca_file         = optional(string, null)<br>    repository_username        = optional(string, null)<br>    repository_password        = optional(string, null)<br>    verify                     = optional(bool, false)<br>    recreate_pods              = optional(bool, false)<br>    devel                      = optional(string, null)<br>    keyring                    = optional(string, "/.gnupg/pubring.gpg")<br>    skip_crds                  = optional(bool, false)<br>    render_subchart_notes      = optional(bool, true)<br>    wait_for_jobs              = optional(bool, false)<br>    replace                    = optional(bool, false)<br>    #    postrender                 = optional(object({<br>    #      binary_path              = optional(string, null)<br>    #      args                     = optional(list(string), [null])<br>    #      }))<br>  })</pre> | n/a | yes |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_controller_service_account_policy_id"></a> [application\_controller\_service\_account\_policy\_id](#output\_application\_controller\_service\_account\_policy\_id) | ArgoCD application-controller IAM policy ID |
| <a name="output_application_controller_service_account_policy_name"></a> [application\_controller\_service\_account\_policy\_name](#output\_application\_controller\_service\_account\_policy\_name) | ArgoCD application-controller IAM policy name |
| <a name="output_application_controller_service_account_role_arn"></a> [application\_controller\_service\_account\_role\_arn](#output\_application\_controller\_service\_account\_role\_arn) | ArgoCD application-controller IAM role ARN |
| <a name="output_argocd_password"></a> [argocd\_password](#output\_argocd\_password) | Argocd raw password |
| <a name="output_argocd_password_encrypted"></a> [argocd\_password\_encrypted](#output\_argocd\_password\_encrypted) | Argocd encrypted password |
| <a name="output_metadata"></a> [metadata](#output\_metadata) | Block status of the deployed ArgoCD |
| <a name="output_server_service_account_policy_id"></a> [server\_service\_account\_policy\_id](#output\_server\_service\_account\_policy\_id) | ArgoCD server IAM policy ID |
| <a name="output_server_service_account_policy_name"></a> [server\_service\_account\_policy\_name](#output\_server\_service\_account\_policy\_name) | ArgoCD server IAM policy name |
| <a name="output_server_service_account_role_arn"></a> [server\_service\_account\_role\_arn](#output\_server\_service\_account\_role\_arn) | ArgoCD server IAM role ARN |
<!-- END_TF_DOCS -->

    ## License
    The Apache-2.0 license

sort:
  enabled: true
  by: required

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  required: true
  sensitive: true
  type: true
