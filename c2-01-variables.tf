variable "aws_region" {
  description = "Region in which AWS Resources to be created. Default region is `us-east-1`"
  type        = string
  default     = "us-east-1"
}



#################################################
# VPC Setting
# Use for both AWS Managed AD & FSx for Windows
#################################################
variable "subnet_ids" {
  description = "A list of IDs for the subnets that the file system will be accessible from. To specify more than a single subnet set `deployment_type` to `MULTI_AZ_1`"
  type        = list(string)
  default     = []
  validation {
    condition     = length(distinct([for subnet_id in var.subnet_ids : data.aws_subnet.selected[subnet_id].availability_zone])) >= 2
    error_message = "You must provide at least two subnets in different availability zones."
  }
}
#######################################
# AWS Directory Service (AD)
#######################################
variable "ad_fqdn_name" {
  description = "(Optional) The fully qualified domain name (FQDN) of the directory (e.g., `corp.example.com`). Required only when not attaching a self-managed AD."
  type        = string
  default     = ""
}

variable "ad_admin_password" {
  description = "(Optional) The password for the directory administrator user .If not specified, a new password will be automatically generated"
  type        = string
  default     = ""
}

variable "ad_edition" {
  description = "(Optional, for type `MicrosoftAD` only) The `MicrosoftAD` edition (`Standard` or `Enterprise`). Defaults to `Standard`"
  type        = string
  default     = "Standard"
}


variable "vpc_id" {
  description = "(Required) The identifier of the VPC that the directory is in."
  type        = string
  default     = "MicrosoftAD"
}


#######################################
# FSx for Windows File Server
#######################################
variable "active_directory_id" {
  description = "(Optional) The ID of an existing AWS Managed Microsoft Active Directory for the file system to join. If not specified, a new AWS Managed AD will be created. Cannot be used with `self_managed_active_directory`."
  type        = string
  default     = ""
}

variable "aliases" {
  description = "(Optional) An array of DNS alias names that you want to associate with the Amazon FSx file system."
  type        = list(string)
  default     = []
}

variable "preferred_subnet_id" {
  description = "Specifies the subnet in which you want the preferred file server to be located. Required when deployment type is `MULTI_AZ_1`."
  type        = string
  default     = ""
}

variable "deployment_type" {
  description = "(Optional) Specifies the file system deployment type. Valid values are `MULTI_AZ_1`, `SINGLE_AZ_1`, and `SINGLE_AZ_2`. Default value is `MULTI_AZ_1`."
  type        = string
  default     = "MULTI_AZ_1"
  validation {
    condition     = contains(["MULTI_AZ_1", "SINGLE_AZ_1", "SINGLE_AZ_2"], var.deployment_type)
    error_message = "Deployment type must be one of `MULTI_AZ_1`, `SINGLE_AZ_1`, or `SINGLE_AZ_2`."
  }
}

variable "storage_type" {
  description = "(Optional) Specifies the storage type. Valid values are `SSD` and `HDD`. `HDD` is supported only with `SINGLE_AZ_2` and `MULTI_AZ_1` deployment types. Default value is `SSD`."
  type        = string
  default     = "SSD"
  validation {
    condition     = contains(["SSD", "HDD"], var.storage_type)
    error_message = "Storage type must be either `SSD` or `HDD`."
  }
}

variable "storage_capacity" {
  description = "(Optional) Storage capacity (GiB) of the file system. Minimum of 32 and maximum of 65536. For `HDD`, the minimum value is 2000. Default is 80 GiB."
  type        = number
  default     = 80
}

variable "throughput_capacity" {
  description = "(Required) Throughput (megabytes per second) of the file system. Maximum is 2048 MB/s. Default is 1024 MB/s."
  type        = number
  default     = 1024
}

variable "automatic_backup_retention_days" {
  description = "(Optional) The number of days to retain automatic backups. Minimum of 0 and maximum of 90. Defaults to 7. Set to 0 to disable backups."
  type        = number
  default     = 7
}

variable "disk_iops_configuration" {
  description = "(Optional) The SSD IOPS configuration for the Amazon FSx for Windows File Server file system."
  type = object({
    iops = number
    mode = string
  })
  default = {
    iops = 40000
    mode = "USER_PROVISIONED"
  }
}

variable "audit_log_configuration" {
  description = "(Optional) Configuration for auditing file system access and file share access logs."
  type = object({
    audit_log_destination             = string
    file_access_audit_log_level       = string
    file_share_access_audit_log_level = string
  })
  default = {
    audit_log_destination             = null
    file_access_audit_log_level       = "DISABLED"
    file_share_access_audit_log_level = "DISABLED"
  }
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

