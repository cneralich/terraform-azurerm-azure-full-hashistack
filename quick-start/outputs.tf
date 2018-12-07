output "jumphost_ips_public" {
  value = "${module.network_azure.jumphost_ips_public}"
}

output "jumphost_username" {
  value = "${module.network_azure.jumphost_username}"
}

output "subnet_public_ids" {
  value = "${module.network_azure.subnet_public_ids}"
}

output "subnet_private_ids" {
  value = "${module.network_azure.subnet_private_ids}"
}