output "argocd_password" {
#  value = length(one(random_password.argocd_password[*].result)) > 0 ? nonsensitive(one(random_password.argocd_password[*].result)) : one(random_password.argocd_password[*].result)
  value = try(nonsensitive(one(random_password.argocd_password[*].result)))
#  value = nonsensitive(random_password.argocd_password.result)
  description = "Argocd raw password"
}
output "argocd_password_encrypted" {
#  value = bcrypt(random_password.argocd_password[0].result, 10)
#  coalesce(var.foo_coalesce, "HelloWorld")
#  value = nonsensitive(bcrypt(one(random_password.argocd_password[*].result), 10))
  value = coalesce(nonsensitive(bcrypt(one(random_password.argocd_password[*].result), 10)), "qwer")
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
