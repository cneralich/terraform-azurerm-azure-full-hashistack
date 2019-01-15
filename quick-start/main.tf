/*
# ---------------------------------------------------------------------------------------------------------------------
#  Helpful Testing Resources
# ---------------------------------------------------------------------------------------------------------------------
module "network_azure" {
  source               = "git@github.com:hashicorp-modules/network-azure.git"
  name                 = "${azurerm_resource_group.hashistack.name}"
  environment_name     = "${var.name}"
  location             = "${var.azure_region}"
  os                   = "${var.azure_os}"
  public_key_data      = "${var.admin_public_key_openssh}"
  jumphost_vm_size     = "${var.azure_vm_size}"
  network_cidrs_public = []
}
*/

data "template_file" "hashistack_init" {
  template = "${file("${path.module}/templates/init-systemd.sh.tpl")}"

  vars = {
    name      = "${var.name}"
    user_data = "${var.azure_vm_custom_data != "" ? var.azure_vm_custom_data : "echo 'No custom user_data'"}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
#  Azure General Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "hashistack" {
  name     = "${var.name}"
  location = "${var.azure_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
#  Azure Load Balancer Resources
# ---------------------------------------------------------------------------------------------------------------------
module "hashistack_lb_azure" {
  source               = "git@github.com:hashicorp-modules/hashistack-lb-azure.git"
  name                 = "${var.name}"
  azure_region         = "${var.azure_region}"
  azure_nat_pool_count = "${var.azure_asg_initial_vm_count}"
}


# ---------------------------------------------------------------------------------------------------------------------
#  Azure Network Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_network_security_group" "hashistack" {
  name                = "${var.name}"
  location            = "${var.azure_region}"
  resource_group_name = "${element(concat(azurerm_resource_group.hashistack.*.name, list("")), 0)}"

  security_rule {
    name                       = "http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "https"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "tcp_4646"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4646"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "tcp_8080"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "tcp_8200"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "tcp_8500"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 106
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_machine_scale_set" "hashistack" {
  name                = "${var.name}"
  location            = "${var.azure_region}"
  resource_group_name = "${element(concat(azurerm_resource_group.hashistack.*.name, list("")), 0)}"

  upgrade_policy_mode = "Manual"

  sku {
    name     = "${var.azure_vm_size}"
    tier     = "Standard"
    capacity = "${var.azure_asg_initial_vm_count}"
  }

  // TODO
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

    # Configure runtime installation with the templated scripts
    custom_data = "${data.template_file.hashistack_init.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path = "/home/${var.admin_username}/.ssh/authorized_keys"

      key_data = "${var.admin_public_key_openssh}"
    }
  }

  network_profile {
    name                      = "${var.name}"
    primary                   = true
    network_security_group_id = "${azurerm_network_security_group.hashistack.id}"

    ip_configuration {
      name      = "${var.name}"
      primary   = "True"
      subnet_id = "${var.azure_subnet_id}"
      // subnet_id = "${module.network_azure.subnet_public_ids[0]}"

      load_balancer_backend_address_pool_ids = ["${module.hashistack_lb_azure.backend_address_pool_id}"]

      load_balancer_inbound_nat_rules_ids = "${module.hashistack_lb_azure.inbound_nat_rules_ids}"
    }
  }

  tags {
    environment = "${var.environment}"
  }
}
