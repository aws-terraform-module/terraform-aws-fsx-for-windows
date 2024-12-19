variable "subnet_ids" {
  description = "List of subnet IDs to be used for FSx and Directory Service."
  type        = list(string)
}

data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

locals {
  # Map subnets to their AZs
  subnets_by_az = {
    for subnet_id, subnet_data in data.aws_subnet.selected : subnet_data.availability_zone => subnet_id
  }

  # Ensure distinct AZs and take the first 2
  directory_service_subnets = slice(values(local.subnets_by_az), 0, 2)
}

# AWS Directory Service
resource "aws_directory_service_directory" "ad" {
  name     = "example.com"
  password = "SuperSecretPassword123!"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = data.aws_vpc.selected.values[0].vpc_id
    subnet_ids = local.directory_service_subnets
  }

  tags = {
    Name = "example-ad"
  }
}

# AWS FSx
resource "aws_fsx_windows_file_system" "fsx" {
  storage_capacity    = 300
  subnet_ids          = var.subnet_ids # All subnets can be used here
  security_group_ids  = [aws_security_group.example.id]
  throughput_capacity = 32

  tags = {
    Name = "example-fsx"
  }
}
