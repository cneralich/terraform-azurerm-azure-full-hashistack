# ---------------------------------------------------------------------------------------------------------------------
# General Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  default = "hashistack-quick-start-azure"
}

variable "provider" {
  default = "azure"
}

variable "local_ip_url" {
  default = "http://169.254.169.254/latest/meta-data/local-ipv4"
}

variable "admin_username" {
  default = "hashistack"
}

variable "admin_password" {
  default = "pTFE1234!"
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "azure_region" {
  default = "eastus"
}

variable "azure_os" {
  # NB: Do not change for now, as only Ubuntu and one version of RHEL 
  # accept custom data for runtime configuration.
  default = "ubuntu"
}

variable "azure_vm_size" {
  default = "Standard_DS1_V2"
}
variable "azure_tags" {
  type    = "map"
  default = {}
}

# ---------------------------------------------------------------------------------------------------------------------
# HashiStack Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "hashistack_servers" {
  default = -1
}

variable "hashistack_consul_version" {
  default = "1.2.3"
}

variable "hashistack_vault_version" {
  default = "0.11.3"
}

variable "hashistack_nomad_version" {
  default = "0.8.6"
}

variable "hashistack_consul_url" {
  default = ""
}

variable "hashistack_vault_url" {
  default = ""
}

variable "hashistack_nomad_url" {
  default = ""
}

variable "hashistack_public" {
  description = "If true, assign a public IP, open port 22 for public access, & provision into public subnets to provide easier accessibility without a Bastion host - DO NOT DO THIS IN PROD"
  default     = true
}

variable "consul_server_config_override" {
  default = ""
}

variable "consul_client_config_override" {
  default = ""
}

variable "vault_config_override" {
  default = ""
}

variable "nomad_config_override" {
  default = ""
}

variable "nomad_client_docker_install" {
  default = false
}

variable "nomad_client_java_install" {
  default = false
}



/*
name     = "${var.environment_name}"
location = "${var.location}"
location              = "${var.location}"
network_cidrs_private = "${var.network_cidrs_private}"
network_cidrs_public  = "${var.network_cidrs_public}"
os                    = "${var.os}"
public_key_data       = "${module.ssh_key.public_key_data}"
custom_data
*/