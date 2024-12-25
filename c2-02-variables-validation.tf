#######################
# Subnets Validation
#######################

# Fetch subnet details for provided subnet IDs
data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.key
}

locals {
  # Extract the availability zones for each subnet
  subnet_azs = [for s in data.aws_subnet.selected : s.availability_zone]

  # Validation: Ensure at least two distinct availability zones if subnets are provided
  validate_subnet_ids = length(var.subnet_ids) > 0 ? length(distinct(local.subnet_azs)) >= 2 : true

  # Validation: Ensure preferred subnet ID (if provided) is in the list of subnet IDs
  validate_preferred_subnet = length(var.subnet_ids) > 0 ? contains(var.subnet_ids, var.preferred_subnet_id) : true
}

# Null resource to enforce validations
resource "null_resource" "validate_subnets" {
  count = local.validate_subnet_ids && local.validate_preferred_subnet ? 0 : 1

  provisioner "local-exec" {
    command = <<EOT
    echo "Validation failed: 
    - Ensure subnet_ids contains subnets from at least two distinct availability zones.
    - Ensure preferred_subnet_id (if provided) is included in the list of subnet IDs."
    exit 1
    EOT
  }
}
