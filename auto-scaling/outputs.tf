 output "public_ip" {
     value = "${azurerm_public_ip.hashistack.fqdn}"
 }

output "ssh_user" {
    value = "${var.admin_username}"
}

output "ssh_key_path" {
    value = "${var.admin_username}"
}