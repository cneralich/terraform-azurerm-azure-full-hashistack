terraform {
  required_version = ">= 0.11.1"
}

# ---------------------------------------------------------------------------------------------------------------------
# Hashistack General Azure Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "hashistack_azure_resource_group" {
  name     = "${var.name}"
  location = "${var.azure_region}"
}

module "ssh_key" {
  source = "git@github.com:hashicorp-modules/terraform-tls-ssh-keypair-data.git"
}

module "network_azure" {
  source = "git@github.com:hashicorp-modules/network-azure.git"
  environment_name      = "${var.name}"
  resource_group_name   = "${azurerm_resource_group.hashistack_azure_resource_group.name}"
  location              = "${var.azure_region}"
  os                    = "${var.azure_os}"
  public_key_data       = "${module.ssh_key.public_key_openssh}"
  custom_data = <<EOF
${data.template_file.base_install.rendered} # Runtime install base tools
${data.template_file.consul_install.rendered} # Runtime install Consul in -dev mode
${data.template_file.vault_install.rendered} # Runtime install Vault in -dev mode
${data.template_file.nomad_install.rendered} # Runtime install Nomad in -dev mode
${data.template_file.hashistack_quick_start.rendered} # Configure HashiStack quick start
EOF
}