output "argocd_password" {
  value = random_password.argocd_password.result
  description = "Argocd raw password"
}
output "argocd_password_encrypted" {
  value = random_password.argocd_password.result
  description = "Argocd encrypted password"
}

output "metadata" {
  value       = try(helm_release.argocd[0].metadata, null)
  description = "Block status of the deployed ArgoCD"
}

output "server_service_account_role_arn" {
  value       = module.argocd_server_iam_role.service_account_role_arn
  description = "ArgoCD server IAM role ARN"
}

output "server_service_account_policy_name" {
  value       = module.argocd_server_iam_role.service_account_policy_name
  description = "ArgoCD server IAM policy name"
}

output "server_service_account_policy_id" {
  value       = module.argocd_server_iam_role.service_account_policy_id
  description = "ArgoCD server IAM policy ID"
}

output "application_controller_service_account_role_arn" {
  value       = module.argocd_application_controller_iam_role.service_account_role_arn
  description = "ArgoCD application-controller IAM role ARN"
}

output "application_controller_service_account_policy_name" {
  value       = module.argocd_application_controller_iam_role.service_account_policy_name
  description = "ArgoCD application-controller IAM policy name"
}

output "application_controller_service_account_policy_id" {
  value       = module.argocd_application_controller_iam_role.service_account_policy_id
  description = "ArgoCD application-controller IAM policy ID"
}
