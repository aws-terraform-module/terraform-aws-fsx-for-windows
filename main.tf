locals {
  ad_admin_password_create = length(var.ad_admin_password) == 0
  ad_admin_password        = local.ad_admin_password_create ? random_password.ad_admin_password[0].result : try(var.ad_admin_password[0], "")
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

resource "aws_directory_service_directory" "bar" {
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
resource "aws_fsx_windows_file_system" "example" {
  active_directory_id = aws_directory_service_directory.example.id
  # kms_key_id          = aws_kms_key.example.arn # Uncomment and provide if using KMS for encryption

  storage_type        = var.storage_type
  storage_capacity    = var.storage_capacity
  subnet_ids          = [aws_subnet.example.id]
  deployment_type     = var.deployment_type
  throughput_capacity = var.throughput_capacity

  disk_iops_configuration {
    iops = var.disk_iops
    mode = "USER_PROVISIONED"
  }

  tags = var.tags
}

