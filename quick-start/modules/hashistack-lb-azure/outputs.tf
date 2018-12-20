output "backend_address_pool_id" {
    value = "${azurerm_lb_backend_address_pool.lb_azure.id}"
}
output "inbound_nat_rules_ids" {
    value = "${azurerm_lb_nat_pool.lb_azure.*.id}"
}
output "public_ip_address" {
    value = "${azurerm_public_ip.lb_azure.ip_address}"
}

output "public_fqdn" {
    value = "${azurerm_public_ip.lb_azure.fqdn}"
}