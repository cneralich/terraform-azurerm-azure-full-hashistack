# ---------------------------------------------------------------------------------------------------------------------
# General Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "The name to use on all of the resources."
  default = "hashistack-quick-start-azure"
}
variable "provider" {
  description = "TODO"
  default = "azure"
}

variable "environment" {
  description = "Name of the environment for resource tagging (ex: dev, prod, etc)."
  default = "demo"
}
variable "local_ip_url" {
  description = "TODO"
  default = "http://checkip.amazonaws.com"
}
variable "admin_username" {
  description = "The username to use for each VM."
  default = "hashistack"
}
variable "admin_password" {
  description = "The password to use for each VM."
  default = "pTFE1234!"
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "azure_region" {
  description = "The Azure Region to use for all resources (ex: westus, eastus)."
  default = "westus"
}
variable "azure_os" {
  description = "The operating system to use on each VM."
  #################################################################################
  # Do not change for now, as only a few Linux versions support cloud-init for now 
  # https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init
  #################################################################################
  default = "ubuntu"
}
variable "azure_vm_size" {
  description = "The size to use for each VM."
  default = "Standard_DS1_V2"
}
variable "azure_vnet_cidr_block_public" {
  description = "TODO"
  type    = "string"
  default = "172.31.0.0/20"
}
variable "azure_vnet_cidr_block_private" {
  description = "TODO"
  type    = "string"
  default = "172.31.16.0/20"
}

# ---------------------------------------------------------------------------------------------------------------------
# HashiStack Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "hashistack_consul_version" {
  description = "TODO"
  default = "1.2.3"
}

variable "hashistack_vault_version" {
  description = "TODO"
  default = "0.11.3"
}

variable "hashistack_nomad_version" {
  description = "TODO"
  default = "0.8.6"
}

variable "hashistack_consul_url" {
  description = "TODO"
  default = ""
}

variable "hashistack_vault_url" {
  description = "TODO"
  default = ""
}

variable "hashistack_nomad_url" {
  description = "TODO"
  default = ""
}

variable "hashistack_public" {
  description = "If true, assign a public IP, open port 22 for public access, & provision into public subnets to provide easier accessibility without a Bastion host - DO NOT DO THIS IN PROD"
  default     = true
}

variable "consul_server_config_override" {
  description = "TODO"
  default = ""
}

variable "consul_client_config_override" {
  description = "TODO"
  default = ""
}

variable "vault_config_override" {
  description = "TODO"
  default = ""
}

variable "nomad_config_override" {
  description = "TODO"
  default = ""
}

variable "nomad_client_docker_install" {
  description = "TODO"
  default = false
}

variable "nomad_client_java_install" {
  description = "TODO"
  default = false
}