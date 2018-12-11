output "jumphost_username" {
  description = "Username to log into the jumphost(s)."
  value = "${module.network_azure.jumphost_username}"
}

output "jumphost_ips_public" {
  description = "IP addresses for the jumphost(s)."
  value = "${module.network_azure.jumphost_ips_public}"
}

/*
output "quick_jumphost_ssh_string" {
  value = "ssh -i private-key.pem ${module.network_azure.jumphost_username}@${module.network_azure.jumphost_ips_public[0]}"
}
output "consul_ui" {
  value = "http://${length(module.hashistack_lb.azurerm_public_ip_address) > 0 ? module.hashistack_lb.azurerm_public_ip_address[0] : "localhost" }:8500/ui"
}

output "vault_ui" {
  value = "http://${length(module.hashistack_lb.azurerm_public_ip_address) > 0 ? module.hashistack_lb.azurerm_public_ip_address[0] : "localhost" }:8200/ui"
}
*/