# ---------------------------------------------------------------------------------------------------------------------
#  SSH Module
# ---------------------------------------------------------------------------------------------------------------------

module "ssh_key" {
  source = "github.com/hashicorp-modules/ssh-keypair-data.git"
}

# ---------------------------------------------------------------------------------------------------------------------
#  Azure General Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "hashistack" {
  name     = "${var.name}-rg"
  location = "West US 2"
}

# ---------------------------------------------------------------------------------------------------------------------
#  Azure Network Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_virtual_network" "hashistack" {
  name                = "${var.name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.hashistack.location}"
  resource_group_name = "${azurerm_resource_group.hashistack.name}"
}

resource "azurerm_subnet" "hashistack" {
  name                 = "${var.name}-subnet"
  resource_group_name  = "${azurerm_resource_group.hashistack.name}"
  virtual_network_name = "${azurerm_virtual_network.hashistack.name}"
  address_prefix       = "10.0.2.0/24"
}
resource "azurerm_public_ip" "hashistack" {
  name                         = "${var.name}-ip"
  location                     = "${azurerm_resource_group.hashistack.location}"
  resource_group_name          = "${azurerm_resource_group.hashistack.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${azurerm_resource_group.hashistack.name}"

  tags {
    environment = "${var.environment}"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
#  Azure Load Balancer Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_lb" "hashistack" {
  name                = "${var.name}-lb"
  location            = "${azurerm_resource_group.hashistack.location}"
  resource_group_name = "${azurerm_resource_group.hashistack.name}"

  frontend_ip_configuration {
    name                 = "${var.name}-public_ip"
    public_ip_address_id = "${azurerm_public_ip.hashistack.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = "${azurerm_resource_group.hashistack.name}"
  loadbalancer_id     = "${azurerm_lb.hashistack.id}"
  name                = "${var.name}-backend-address-pool"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  count                          = 3
  resource_group_name            = "${azurerm_resource_group.hashistack.name}"
  name                           = "${var.name}-public-ip-address"
  loadbalancer_id                = "${azurerm_lb.hashistack.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "${var.name}-public_ip"
}

# ---------------------------------------------------------------------------------------------------------------------
#  Azure Auto Scaler Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_virtual_machine_scale_set" "hashistack" {
  name                = "${var.name}_scale-set-1"
  location            = "${azurerm_resource_group.hashistack.location}"
  resource_group_name = "${azurerm_resource_group.hashistack.name}"

  upgrade_policy_mode  = "Manual"

  sku {
    name     = "${var.azure_instance_type}"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "${var.name}"
    admin_username       = "${var.admin_username}"
    admin_password       = "${var.admin_password}"
    custom_data = <<EOF
${data.template_file.base_install.rendered} # Runtime install base tools
${data.template_file.consul_install.rendered} # Runtime install Consul in -dev mode
${data.template_file.vault_install.rendered} # Runtime install Vault in -dev mode
${data.template_file.nomad_install.rendered} # Runtime install Nomad in -dev mode
${data.template_file.hashistack_quick_start.rendered} # Configure HashiStack quick start
EOF
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${module.ssh_key.public_key_openssh}"
    }
  }

  network_profile {
    name    = "${var.name}-network-profile"
    primary = true

    ip_configuration {
      name                                   = "${var.name}-test-ip-configuration"
      primary                                = true
      subnet_id                              = "${azurerm_subnet.hashistack.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbnatpool.*.id, count.index)}"]
    }
  }

  tags {
    environment = "${var.environment}"
  }
}