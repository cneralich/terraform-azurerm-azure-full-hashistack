# ---------------------------------------------------------------------------------------------------------------------
#  Azure General Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "hashistack" {
  name     = "${var.name}"
  location = "${var.azure_region}"
}
module "ssh_key" {
  source = "github.com/hashicorp-modules/ssh-keypair-data.git"
}

# ---------------------------------------------------------------------------------------------------------------------
#  Azure Network Resources
# ---------------------------------------------------------------------------------------------------------------------
module "network_azure" {
  source = "git@github.com:hashicorp-modules/network-azure.git"
  resource_group_name   = "${azurerm_resource_group.hashistack.name}"
  environment_name      = "${var.environment}"
  location              = "${var.azure_region}"
  os                    = "${var.azure_os}"
  public_key_data       = "${module.ssh_key.public_key_openssh}"
  jumphost_vm_size      = "${var.azure_vm_size}"
  network_cidrs_public  = ["${var.azure_vnet_cidr_block_public}"]

  # Configure runtime installation with the templated scripts
  custom_data = <<EOF
${data.template_file.base_install.rendered}
${data.template_file.consul_install.rendered}
${data.template_file.vault_install.rendered}
${data.template_file.nomad_install.rendered}
${data.template_file.hashistack_quick_start.rendered}
${data.template_file.java_install.rendered}
${data.template_file.docker_install.rendered}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
#  Azure Load Balancer Resources
# ---------------------------------------------------------------------------------------------------------------------
module "hashistack_lb" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${azurerm_resource_group.hashistack.name}"
  location            = "${azurerm_resource_group.hashistack.location}"
  prefix              = "consul"

  "remote_port" {
    ssh = ["Tcp", "22"]
  }

  "lb_port" {
    http = ["80", "Tcp", "80"]
    https = ["443", "Tcp", "443"]
    tcp_8200 = ["4646", "Tcp", "4646"]
    tcp_8080 = ["8080", "Tcp", "8080"]
    tcp_8200 = ["8200", "Tcp", "8200"]
    tcp_8500 = ["8500", "Tcp", "8500"]
    tcp_8501 = ["8501", "Tcp", "8501"]
  }
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
    name     = "${var.azure_vm_size}"
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

    # Configure runtime installation with the templated scripts
    custom_data = <<EOF
${data.template_file.base_install.rendered}
${data.template_file.consul_install.rendered}
${data.template_file.vault_install.rendered}
${data.template_file.nomad_install.rendered}
${data.template_file.hashistack_quick_start.rendered}
${data.template_file.java_install.rendered}
${data.template_file.docker_install.rendered}
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
    name    = "${var.name}"
    primary = true

    ip_configuration {
      name                                   = "${var.name}"
      primary                                = true
      subnet_id                              = "${module.network_azure.subnet_public_ids[0]}"
      load_balancer_backend_address_pool_ids = [
        "${module.hashistack_lb.azurerm_lb_backend_address_pool_id}"
      ]
    }
  }

  tags {
    environment = "${var.environment}"
  }
}