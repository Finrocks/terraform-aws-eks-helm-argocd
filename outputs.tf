output "metadata" {
  value       = try(helm_release.default[0].metadata, null)
  description = "Block status of the deployed ArgoCD"
}

output "server_service_account_role_arn" {
  value       = module.server_eks_iam_role.service_account_role_arn
  description = "ArgoCD server IAM role ARN"
}

output "server_service_account_policy_name" {
  value       = module.server_eks_iam_role.service_account_policy_name
  description = "ArgoCD server IAM policy name"
}

output "server_service_account_policy_id" {
  value       = module.server_eks_iam_role.service_account_policy_id
  description = "ArgoCD server IAM policy ID"
}

output "application_controller_service_account_role_arn" {
  value       = module.application_controller_eks_iam_role.service_account_role_arn
  description = "ArgoCD application-controller IAM role ARN"
}

output "application_controller_service_account_policy_name" {
  value       = module.application_controller_eks_iam_role.service_account_policy_name
  description = "ArgoCD application-controller IAM policy name"
}

output "application_controller_service_account_policy_id" {
  value       = module.application_controller_eks_iam_role.service_account_policy_id
  description = "ArgoCD application-controller IAM policy ID"
}
