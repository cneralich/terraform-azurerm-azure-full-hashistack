output "quick_jumphost_ssh_string" {
  description = "Copy paste this string to SSH into the jumphost."
  value       = "ssh -i private-key.pem ${module.network_azure.jumphost_username}@${module.network_azure.jumphost_ips_public[0]}"
}

output "consul_ui" {
  description = "Use this link to access the Consul UI."
  value       = "http://${module.hashistack_lb.azurerm_public_ip_address[0]}:8500/ui"
}

output "vault_ui" {
  description = "Use this link to access the Vault UI."
  value       = "http://${module.hashistack_lb.azurerm_public_ip_address[0]}:8200/ui"
}

output "nomad_ui" {
  description = "Use this link to access the Nomad UI."
  value       = "http://${module.hashistack_lb.azurerm_public_ip_address[0]}:4646/ui"
}
