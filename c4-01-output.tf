output "AD_username" {
  description = "AWS Managed AD admin username"
  value       = try(aws_directory_service_directory.ad[0].name, "")
}

output "AD_password" {
  description = "AWS Managed AD admin password"
  value       = try(aws_directory_service_directory.ad[0].password, "")
}
