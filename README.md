# Azure HashiStack Terraform Module

_Provisions resources for a HashiStack auto-scaling group in Azure. This does not auto-install the HashiStack, that information must be provided as `custom_data`._

## Deployment Prerequisites

1. In order to perform the steps in this guide, you will need to have an Azure subscription for which you can create Service Principals as well as network and compute resources. You can create a free Azure account [here](https://azure.microsoft.com/en-us/free/).

2. Certain steps will require entering commands through the Azure CLI. You can find out more about installing it [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

3. Create Azure API Credentials: set up the main Service Principal that will be used for Packer and Terraform:
    * [https://www.terraform.io/docs/providers/azurerm/index.html]()
    * The above steps will create a Service Principal with the [Contributor](https://docs.microsoft.com/en-us/azure/active-directory/role-based-access-built-in-roles#contributor) role in your Azure subscription

4. `export` environment variables for the main (Packer/Terraform) Service Principal. For example, create an `env.sh` file with the following values (obtained from step `1` above):

    ```
    # Exporting variables in both cases just in case, no pun intended
    export ARM_SUBSCRIPTION_ID="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
    export ARM_CLIENT_ID="bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
    export ARM_CLIENT_SECRET="cccccccc-cccc-cccc-cccc-cccccccccccc"
    export ARM_TENANT_ID="dddddddd-dddd-dddd-dddd-dddddddddddd"
    export subscription_id="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
    export client_id="bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
    export client_secret="cccccccc-cccc-cccc-cccc-cccccccccccc"
    ```

5. Finally, create a read-only Azure Service Principal (using the Azure CLI) that will be used to perform the Consul auto-join (make note of these values as you will use them later in this guide):

    ```
    $ az ad sp create-for-rbac --role="Reader" --scopes="/subscriptions/[YOUR_SUBSCRIPTION_ID]"
    ```

## Modules

### Helpful

These modules can be used to populate required input variables for the auto scaling group, which is helpful for testing. They are commented out in the `main.tf` file for ease of access.

- [Keypair Terraform Module](https://github.com/hashicorp-modules/ssh-keypair-data)
  - `public_key_openssh` --> `public_key_openssh`
- [Network Azure Terraform Module](https://github.com/hashicorp-modules/network-azure/)
  - `subnet_public_ids` --> `subnet_ids`

## Variables

### Required

- `name`: The name to use on all of the resources.
- `admin_public_key_openssh`: The SSH public key data to use for each VM.
- `admin_password`: The password to use for each VM.
- `azure_subnet_id`: Subnet ID to provision resources in.

### Optional

- `environment`: Name of the environment for resource tagging (ex: dev, prod, etc).
- `provider`: Provider name to be used in the templated scripts run as part of cloud-init
- `local_ip_url`: The URL to use to get a resource's IP address at runtime.
- `admin_username`: The username to use for each VM.
- `azure_region`: The Azure Region to use for all resources (ex: West US, East US).
- `azure_os`: The operating system to use on each VM.
- `azure_vm_size`: The size to use for each VM.
- `azure_vm_custom_data`: Custom data script to pass and execute on each VM at bootup.
- `azure_asg_initial_vm_count`: The number of VMs to spin up in the autoscaling group initially.

## Outputs

- `quick_jumphost_ssh_string`: Copy paste this string to SSH into the jumphost.
- `consul_ui`: Use this link to access the Consul UI.
- `vault_ui`: Use this link to access the Vault UI.
- `nomad_ui`: Use this link to access the Nomad UI.

## Viewing Logs

Example of viewing `cloud-init` logs:

```
$ tail -f /var/log/cloud-init-output.log
```

Example of viewing `consul` server logs:

```
$ journalctl _SYSTEMD_UNIT=consul.service
```

## Authors

HashiCorp Solutions Engineering Team.

## License

Mozilla Public License Version 2.0. See LICENSE for full details.
