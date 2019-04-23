output "lb_fqdn" {
  value = "${module.hashistack_lb_azure.public_fqdn}"
}

output "nomad_ui" {
  value = "http://${module.hashistack_lb_azure.public_fqdn}:4646"
}

output "vault_ui" {
  value = "http://${module.hashistack_lb_azure.public_fqdn}:8200"
}

output "consul_ui" {
  value = "http://${module.hashistack_lb_azure.public_fqdn}:8500"
}

output "lb_public_ip_address" {
  value = "${module.hashistack_lb_azure.public_ip_address}"
}

output "quick_ssh_string" {
  value = "ssh -i id_rsa_${var.name} ${var.admin_username}@${module.hashistack_lb_azure.public_fqdn} -p 50001"
}