# terraform-aws-fsx-for-windows

A Terraform module to deploy and configure Amazon FSx for Windows File Server with AWS Managed Active Directory (AD) integration.

---

## Current Limitations

1. **AWS Managed Active Directory (AD) Only**  
   This module currently supports **only AWS Managed Active Directory**. Integration with other AD types is not available.

2. **No Custom Subnet Specification**  
   Specifying custom subnets for the FSx file system is not supported at this time.

---

## Usage Examples

### Minimal Example
A simple configuration to deploy FSx for Windows:

```hcl
module "fsx-windows" {
  source = "github.com/aws-terraform-module/terraform-aws-fsx-for-windows"

  vpc_id           = "vpc-xxx"
  ad_fqdn_name     = "fsx.demo.local"
  fsx_logical_name = "fsx-windows-demo"
}
```
### Full Example
A full configuration to deploy FSx for Windows:

```hcl

module "fsx-windows" {
  source = "github.com/aws-terraform-module/terraform-aws-fsx-for-windows"

  vpc_id = data.aws_vpc.selected.id

  ###############################
  # AWS Managed AD Configuration
  ###############################
  ad_fqdn_name      = "fsx.demo.local"
  ad_admin_password = "Password@123"
  ad_edition        = "Standard"

  ####################################
  # AWS FSx for Windows Configuration
  ####################################
  fsx_logical_name                = "fsx-windows-demo"
  active_directory_id             = "d-906b4b4b"
  aliases                         = ["example.demo.local", "example2.demo.local"]
  preferred_subnet_id             = "subnet-0b4b4b4b4b4b4b4b4"
  deployment_type                 = "MULTI_AZ_1"
  storage_type                    = "SSD"
  storage_capacity                = 80
  throughput_capacity             = 1024
  automatic_backup_retention_days = 7

  disk_iops_configuration = {
    iops = 40000
    mode = "USER_PROVISIONED"
  }

  audit_log_configuration = {
    audit_log_destination             = null
    file_access_audit_log_level       = "DISABLED"
    file_share_access_audit_log_level = "DISABLED"
  }

  tags = {
    "Service" = "FSx-windows"
  }
}

```
