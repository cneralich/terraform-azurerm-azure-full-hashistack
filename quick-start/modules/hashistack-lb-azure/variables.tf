# ---------------------------------------------------------------------------------------------------------------------
# General Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "The name to use on all of the resources."
  type        = "string"
  default     = "hashistack-lb"
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "azure_region" {
  description = "The Azure Region to use for all resources (ex: westus, eastus)."
  type        = "string"
  default     = "eastus"
}

variable "azure_nat_pool_count" {
  description = "The number of nat pools to spin up for the load balancer."
  type        = "string"
}
