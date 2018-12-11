# Azure HashiStack Terraform Module

Provisions resources for a HashiStack auto-scaling group in Azure. You can view the output of the runtime logs on the Linux box in `/var/log/cloud-init-output.log`.

TODO: add tags


## Environment Variables

```
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID
```

## Variables

### Required

### Optional

## Outputs

- `jumphost_username`: Username for jumphost(s).
- `jumphost_ips_public`: IP address(es) created for jumphost(s).
- `consul_ui_fqdn`: Quick link to the Consul UI. 

## Authors

HashiCorp Solutions Engineering Team.

## License

Mozilla Public License Version 2.0. See LICENSE for full details.
