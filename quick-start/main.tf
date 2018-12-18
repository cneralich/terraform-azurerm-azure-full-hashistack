# ---------------------------------------------------------------------------------------------------------------------
#  SSH Resources
# ---------------------------------------------------------------------------------------------------------------------
module "ssh_key" {
  source = "github.com/hashicorp-modules/ssh-keypair-data.git"
}

# ---------------------------------------------------------------------------------------------------------------------
#  Azure Load Balancer Resources
# ---------------------------------------------------------------------------------------------------------------------
module "hashistack_lb" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${var.name}"
  location            = "${var.azure_region}"
  prefix              = "hashistack"
  frontend_name       = "hashistack"

  "remote_port" {
    ssh = ["Tcp", "22"]
  }

  "lb_port" {
    http     = ["80", "Tcp", "80"]
    https    = ["443", "Tcp", "443"]
    tcp_4646 = ["4646", "Tcp", "4646"]
    tcp_8080 = ["8080", "Tcp", "8080"]
    tcp_8200 = ["8200", "Tcp", "8200"]
    tcp_8500 = ["8500", "Tcp", "8500"]
    tcp_8501 = ["8501", "Tcp", "8501"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
#  Azure Network Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_network_security_group" "hashistack" {
  name                = "${var.name}"
  location            = "${var.azure_region}"
  resource_group_name = "${var.name}"

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
}

# ---------------------------------------------------------------------------------------------------------------------
#  Azure Auto Scaler Resources
# ---------------------------------------------------------------------------------------------------------------------
data "template_file" "hashistack_init" {
  template = "${file("${path.module}/templates/init-systemd.sh.tpl")}"

  vars = {
    name      = "${var.name}"
    user_data = "${var.azure_vm_custom_data != "" ? var.azure_vm_custom_data : "echo 'No custom user_data'"}"
  }
}

resource "azurerm_virtual_machine_scale_set" "hashistack" {
  name                = "${var.name}"
  location            = "${var.azure_region}"
  resource_group_name = "${var.name}"

  upgrade_policy_mode = "Manual"

  sku {
    name     = "${var.azure_vm_size}"
    tier     = "Standard"
    capacity = 2
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
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.admin_public_key_openssh != "" ? var.admin_public_key_openssh : module.ssh_key.public_key_openssh}"
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

      load_balancer_backend_address_pool_ids = [
        "${module.hashistack_lb.azurerm_lb_backend_address_pool_id}",
      ]

      load_balancer_inbound_nat_rules_ids = []
    }
  }

  tags {
    environment = "${var.environment}"
  }
}
