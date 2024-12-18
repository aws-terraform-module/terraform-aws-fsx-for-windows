locals {
  ad_admin_password_create = length(var.ad_admin_password) == 0
  ad_admin_password        = local.ad_admin_password_create ? random_password.ad_admin_password[0].result : try(var.ad_admin_password[0], "")

  active_directory_create = var.active_directory_id == "" ? 1 : 0
  active_directory_id     = local.active_directory_create ? aws_directory_service_directory.ad[0].id : var.active_directory_id
}


###########################
data "aws_vpc" "selected" {
  tags = {
    Name = "dev-mdcl-mdaas-engine" # Replace with your VPC's tag name
  }
}

data "aws_subnets" "private_networks" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}
###########################
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
  type     = var.ad_type

  vpc_settings {
    vpc_id     = data.aws_vpc.selected.id
    subnet_ids = [aws_subnet.foo.id, aws_subnet.bar.id]
  }

  tags = var.tags
}

############# FSX ##############
resource "aws_fsx_windows_file_system" "fsx_windows" {
  active_directory_id = local.active_directory_id

  storage_type        = var.storage_type
  storage_capacity    = var.storage_capacity
  subnet_ids          = [aws_subnet.example.id]
  deployment_type     = var.deployment_type
  throughput_capacity = var.throughput_capacity

  dynamic "disk_iops_configuration" {
    for_each = length(var.disk_iops_configuration) > 0 ? [var.disk_iops_configuration] : []

    content {
      iops = try(disk_iops_configuration.value.iops, null)
      mode = try(disk_iops_configuration.value.mode, null)
    }
  }

  tags = var.tags
}

