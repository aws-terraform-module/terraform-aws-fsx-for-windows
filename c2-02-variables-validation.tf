
#######################
# Subnets Validation
#######################
locals {
  validate_subnet_ids = length(var.subnet_ids) > 0 ? length(distinct([for subnet_id in var.subnet_ids : data.aws_subnet.selected[subnet_id].availability_zone])) >= 2 : true

  validate_preferred_subnet = length(var.subnet_ids) > 0 ? contains(var.subnet_ids, var.preferred_subnet_id) : true
}


resource "null_resource" "validate_subnets" {
  count = local.validate_subnet_ids && local.validate_preferred_subnet ? 0 : 1

  provisioner "local-exec" {
    command = <<EOT
    echo "Validation failed: Ensure subnet_ids contains subnets from at least two availability zones and preferred_subnet_id is one of them."
    exit 1
    EOT
  }
}
