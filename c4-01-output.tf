output "AD_username" {
  description = "AWS Managed AD admin username"
  value       = try(one(aws_directory_service_directory.ad[*]).name, null)
}

output "AD_password" {
  description = "AWS Managed AD admin password"
  value       = try(one(aws_directory_service_directory.ad[*]).password, null)
  sensitive   = true
}

