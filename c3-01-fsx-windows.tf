locals {
  ad_admin_password_create = length(var.ad_admin_password) == 0
  ad_admin_password        = local.ad_admin_password_create ? random_password.ad_admin_password[0].result : try(var.ad_admin_password[0], "")

  active_directory_create = var.active_directory_id == "" ? 1 : 0
  active_directory_id     = local.active_directory_create ? aws_directory_service_directory.ad[0].id : var.active_directory_id

  ##########################################
  # Get 1 subnet per AZ (For AWS Managed AD)
  ##########################################
  subnets_by_az = {
    for subnet_id, subnet_data in data.aws_subnet.selected : subnet_data.availability_zone => subnet_id
  }
  # Take the first 2 subnet
  directory_service_subnets = slice(values(local.subnets_by_az), 0, 2)
}

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
    vpc_id     = data.aws_vpc.selected.values[0].vpc_id # get subnet from vpc_id
    subnet_ids = local.directory_service_subnets
  }

  tags = var.tags
}

############# FSX ##############
resource "aws_fsx_windows_file_system" "fsx_windows" {
  active_directory_id             = local.active_directory_id
  aliases                         = var.aliases
  storage_type                    = var.storage_type
  storage_capacity                = var.storage_capacity
  subnet_ids                      = var.subnet_ids
  preferred_subnet_id             = local.active_directory_create && length(local.directory_service_subnets) > 0 ? local.directory_service_subnets[0] : var.preferred_subnet_id
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

  tags = var.tags
}

