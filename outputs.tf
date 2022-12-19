output "argocd_password" {
  value = try(nonsensitive(one(random_password.argocd_password[*].result)), null)
  description = "Argocd raw password"
}

output "argocd_password_encrypted" {
#  value = try(nonsensitive(bcrypt(one(random_password.argocd_password[*].result), 10)), null)
  value = try(one(data.aws_ssm_parameter.encrypted_password[*].value), null)
  description = "Argocd encrypted password"
}

output "metadata" {
  value       = try(helm_release.argocd[0].metadata, null)
  description = "Block status of the deployed ArgoCD"
}

output "server_service_account_role_arn" {
  value       = one(module.argocd_server_iam_role[*].service_account_role_arn)
  description = "ArgoCD server IAM role ARN"
}

output "server_service_account_policy_name" {
  value       = one(module.argocd_server_iam_role[*].service_account_policy_name)
  description = "ArgoCD server IAM policy name"
}

output "server_service_account_policy_id" {
  value       = one(module.argocd_server_iam_role[*].service_account_policy_id)
  description = "ArgoCD server IAM policy ID"
}

output "application_controller_service_account_role_arn" {
  value       = one(module.argocd_application_controller_iam_role[*].service_account_role_arn)
  description = "ArgoCD application-controller IAM role ARN"
}

output "application_controller_service_account_policy_name" {
  value       = one(module.argocd_application_controller_iam_role[*].service_account_policy_name)
  description = "ArgoCD application-controller IAM policy name"
}

output "application_controller_service_account_policy_id" {
  value       = one(module.argocd_application_controller_iam_role[*].service_account_policy_id)
  description = "ArgoCD application-controller IAM policy ID"
}
