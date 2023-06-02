variable "az_location" {
  type        = string
  default     = "francecentral"
  description = "Azure location for resources"
}

variable "az_res_group" {
  type        = string
  default     = "devbox"
  description = "Azure resource group"
}

variable "devbox_user_login" {
  type        = string
  default     = "devuser"
  description = "User login for the devbox VM"
}

variable "devbox_user_ssh_public" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Public SSH keyfile used for connecting to the devbox VM"
}

variable "devbox_user_ssh_private" {
  type        = string
  default     = "~/.ssh/id_rsa"
  description = "Private SSH keyfile used for connecting to the devbox VM"
}

variable "devbox_vm_size" {
  type        = string
  default     = "Standard_D4s_v3"
  description = "Size for the devbox VM"
}

variable "devbox_disk_size" {
  type        = number
  default     = 30
  description = "Disk size in GB for the devbox VM"
}

variable "devbox_shutdown_time" {
  type        = string
  default     = "2100"
  description = "Time each day when the devbox VM is shut down"
}

// List of timezones supported by Azure:
// https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
variable "devbox_shutdown_timezone" {
  type        = string
  default     = "Romance Standard Time"
  description = "Timezone for shutting down time"
}

variable "devbox_shutdown_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable automatic shutting down for the devbox VM"
}
