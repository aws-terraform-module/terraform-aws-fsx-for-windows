data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.selected.ids)
  id       = each.key
}

locals {
  ad_admin_password_create = length(var.ad_admin_password) == 0
  ad_admin_password        = local.ad_admin_password_create ? random_password.ad_admin_password[0].result : try(var.ad_admin_password[0], "")

  active_directory_create = var.active_directory_id == "" ? true : false
  active_directory_id     = local.active_directory_create ? aws_directory_service_directory.ad[0].id : var.active_directory_id

  ##########################################
  # Get 1 subnet per AZ (For AWS Managed AD)
  ##########################################

  ##########################################
  # Extract subnets & AZs
  ##########################################
  subnets_with_az = {
    for id, subnet in data.aws_subnet.subnet :
    id => subnet.availability_zone
  }

  ##########################################
  # Extracted first 2 subnets (Ensure 2 distinct AZs)
  ##########################################
  extracted_subnets = slice(keys(local.subnets_with_az), 0, 2)

}

###########################################
# AWS Managed AD
###########################################
resource "random_password" "ad_admin_password" {
  count   = local.ad_admin_password_create ? 1 : 0
  length  = 24
  special = false
}

resource "aws_directory_service_directory" "ad" {
  count    = local.active_directory_create ? 1 : 0
  name     = var.ad_fqdn_name
  password = local.ad_admin_password
  edition  = var.ad_edition
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = local.extracted_subnets
  }

  tags = var.tags
}


###########################################
# AWS FSx for Windows File Server
###########################################
resource "aws_fsx_windows_file_system" "fsx_windows" {
  active_directory_id             = local.active_directory_id
  aliases                         = var.aliases
  storage_type                    = var.storage_type
  storage_capacity                = var.storage_capacity
  subnet_ids                      = data.aws_subnets.selected.ids
  preferred_subnet_id             = length(var.preferred_subnet_id) == 0 ? (length(local.extracted_subnets) > 0 ? local.extracted_subnets[0] : null) : var.preferred_subnet_id
  deployment_type                 = var.deployment_type
  throughput_capacity             = var.throughput_capacity
  automatic_backup_retention_days = var.automatic_backup_retention_days

  dynamic "audit_log_configuration" {
    for_each = length(var.audit_log_configuration) > 0 ? [var.audit_log_configuration] : []

    content {
      audit_log_destination             = try(audit_log_configuration.value.audit_log_destination, null)
      file_access_audit_log_level       = try(audit_log_configuration.value.file_access_audit_log_level, null)
      file_share_access_audit_log_level = try(audit_log_configuration.value.file_share_access_audit_log_level, null)
    }
  }

  dynamic "disk_iops_configuration" {
    for_each = length(var.disk_iops_configuration) > 0 ? [var.disk_iops_configuration] : []

    content {
      iops = try(disk_iops_configuration.value.iops, null)
      mode = try(disk_iops_configuration.value.mode, null)
    }
  }


  tags = merge(
    var.tags,
    var.fsx_logical_name != null ? { "Name" = var.fsx_logical_name } : {}
  )
}

