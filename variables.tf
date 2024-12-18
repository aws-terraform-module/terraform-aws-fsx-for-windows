#######################################
# AWS Dicrectory Service (AD)
#######################################
variable "ad_fqdn_name" {
  description = "(Required) The fully qualified name for the directory, such as `corp.example.com`"
  type        = string
  default     = ""
}

variable "ad_admin_password" {
  description = "(Required) The password for the directory administrator or connector user"
  type        = string
  default     = ""
}

variable "ad_edition" {
  description = "(Optional, for type `MicrosoftAD` only) The `MicrosoftAD` edition (`Standard` or `Enterprise`). Defaults to `Standard`"
  type        = string
  default     = "Standard"
}


variable "ad_type" {
  description = " The directory type (`SimpleAD`, `ADConnector` or `MicrosoftAD` are accepted values). Defaults to `MicrosoftAD`"
  type        = string
  default     = "MicrosoftAD"
}


#######################################
# FSx for Windows File Server
#######################################
variable "subnet_ids" {
  description = "A list of IDs for the subnets that the file system will be accessible from. To specify more than a single subnet set `deployment_type` to `MULTI_AZ_1`"
  type        = list(string)
  default     = []
}

variable "deployment_type" {
  description = "(Optional) Specifies the file system deployment type, valid values are `MULTI_AZ_1`, `SINGLE_AZ_1` and `SINGLE_AZ_2`. Default value is `MULTI_AZ_1`"
  type        = string
  default     = "MULTI_AZ_1"
}

variable "storage_type" {
  description = "(Optional) Specifies the storage type, Valid values are `SSD` and `HDD`. `HDD` is supported on `SINGLE_AZ_2` and `MULTI_AZ_1` Windows file system deployment types. Default value is `SSD`"
  type        = string
  default     = "SSD"
}

variable "storage_capacity" {
  description = "(Optional) Storage capacity (GiB) of the file system. Minimum of 32 and maximum of 65536. If the storage type is set to `HDD` the minimum value is 2000. Required when not creating filesystem for a backup. Default value is 80 GiB"
  type        = number
  default     = 80
}

variable "throughput_capacity" {
  description = "(Required) Throughput (megabytes per second) of the file system. Current maximun is 2048 MB/s .Default is 1024 MB/s"
  type        = number
  default     = 1024
}


variable "disk_iops_configuration" {
  description = "The SSD IOPS configuration for the Amazon FSx for Windows File Server file system. Default values comprise: `iops` = 40000 and `mode` = `USER_PROVISIONED` "
  type = object({
    iops = number
    mode = string
  })
  default = {
    iops = 40000
    mode = "USER_PROVISIONED"
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
