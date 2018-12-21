# ---------------------------------------------------------------------------------------------------------------------
# General Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "The name to use on all of the resources (in this case, the Azure Resource Group name as well)."
  type        = "string"
}

variable "provider" {
  description = "Provider name to be used in the templated scripts run as part of cloud-init"
  type        = "string"
  default     = "azure"
}

variable "environment" {
  description = "Name of the environment for resource tagging (ex: dev, prod, etc)."
  type        = "string"
  default     = "demo"
}

variable "local_ip_url" {
  description = "The URL to use to get a resource's IP address at runtime."
  type        = "string"
  default     = "http://checkip.amazonaws.com"
}

variable "admin_username" {
  description = "The username to use for each VM."
  type        = "string"
  default     = "hashistack"
}

variable "admin_password" {
  description = "The password to use for each VM."
  type        = "string"
  default     = "pTFE1234!"
}

variable "admin_public_key_openssh" {
  description = "The SSH public key data to use for each VM."
  type        = "string"
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "azure_region" {
  description = "The Azure Region to use for all resources (ex: westus, eastus)."
  type        = "string"
  default     = "eastus"
}

variable "azure_os" {
  description = "The operating system to use on each VM."
  type        = "string"

  #################################################################################
  # Do not change for now, as only a few Linux versions support cloud-init for now 
  # https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init
  #################################################################################
  default = "ubuntu"
}

variable "azure_vm_size" {
  description = "The size to use for each VM."
  type        = "string"
  default     = "Standard_DS1_V2"
}

variable "azure_asg_initial_vm_count" {
  description = "The number of VMs to spin up in the autoscaling group initially."
  type        = "string"
  default     = "1"
}

variable "azure_vm_custom_data" {
  description = "Custom data script to pass and execute on each VM at bootup."
  type        = "string"
  default     = ""
}

variable "azure_vnet_cidr_block" {
  description = "The public network CIDRs to add to the virtual network."
  type        = "string"
  default     = "172.31.0.0/20"
}

variable "azure_subnet_id" {
  description = "Subnet ID to provision resources in."
  type        = "string"
}

variable "azure_load_balancer_backend_address_pool_ids" {
  description = "TODO"
  type        = "list"
  default     = []
}

variable "azure_load_balancer_inbound_nat_rules_ids" {
  description = "TODO"
  type        = "list"
  default     = []
}

# ---------------------------------------------------------------------------------------------------------------------
# HashiStack Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "hashistack_consul_version" {
  description = "The version number of Consul to install on the VM at runtime."
  default     = "1.2.3"
}

variable "hashistack_vault_version" {
  description = "The version number of Vault to install on the VM at runtime."
  default     = "0.11.3"
}

variable "hashistack_nomad_version" {
  description = "The version number of Nomad to install on the VM at runtime."
  default     = "0.8.6"
}

variable "hashistack_consul_url" {
  description = "URL to download Consul version if internet not accessible."
  default     = ""
}

variable "hashistack_vault_url" {
  description = "URL to download Vault version if internet not accessible."
  default     = ""
}

variable "hashistack_nomad_url" {
  description = "URL to download Nomad version if internet not accessible."
  default     = ""
}

variable "consul_server_config_override" {
  description = "Any additional Consul server coonfiguration to override defaults."
  default     = ""
}

variable "consul_client_config_override" {
  description = "Any additional Consul client coonfiguration to override defaults."
  default     = ""
}

variable "vault_config_override" {
  description = "Any additional Vault coonfiguration to override defaults."
  default     = ""
}

variable "nomad_config_override" {
  description = "Any additional Nomad coonfiguration to override defaults."
  default     = ""
}
