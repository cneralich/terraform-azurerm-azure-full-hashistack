output "zREADME" {
  value = <<README
# ------------------------------------------------------------------------------
# ${var.name} HashiStack Consul - Azure
# ------------------------------------------------------------------------------
You can now interact with Consul using any of the CLI or API commands.
  - https://www.consul.io/docs/commands/index.html
  - https://www.consul.io/api/index.html

Consul UI: http://${module.hashistack_lb.azurerm_public_ip_address[0]}:8500

########################################################################################
# WARNING - DO NOT DO THIS IN PRODUCTION!
# The Nomad nodes are in a public subnet with UI & SSH access open from the internet. 
########################################################################################

Use the CLI to retrieve the Consul members, write a key/value, and read
that key/value.
  $ consul members # Retrieve Consul members
  $ consul kv put cli bar=baz # Write a key/value
  $ consul kv get cli # Read a key/value
Use the HTTP API to retrieve the Consul members, write a key/value,
and read that key/value.

If you're making HTTP API requests to Consul from the Jump host,
the below env var has been set for you.
  $ export CONSUL_ADDR=http://127.0.0.1:8500
  $ curl \\
      -X GET \\
      $${CONSUL_ADDR}/v1/agent/members | jq '.' # Retrieve Consul members
  $ curl \\
      -X PUT \\
      -d '{\"bar=baz\"}' \\
      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Write a KV
  $ curl \\
      -X GET \\
      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Read a KV
}

# ------------------------------------------------------------------------------
# ${var.name} HashiStack Vault - Azure
# ------------------------------------------------------------------------------
To start interacting with Vault from the Jump host follow the below steps to 
set this up.

1.) SSH into one of the Vault servers registered with Consul, you can use the
below command to accomplish this automatically (we'll use Consul DNS moving
forward once Vault is unsealed).
  $ ssh -A ${var.admin_username}@$(curl http://127.0.0.1:8500/v1/agent/members | jq -M -r \
      '[.[] | select(.Name | contains ("${var.name}-hashistack")) | .Addr][0]')

2.) Initialize Vault
  $ vault operator init

3.) Unseal Vault using the "Unseal Keys" output from the `vault init` command
and check the seal status.
  $ vault operator unseal <UNSEAL_KEY_1>
  $ vault operator unseal <UNSEAL_KEY_2>
  $ vault operator unseal <UNSEAL_KEY_3>
  $ vault status

Repeat steps 1.) and 3.) to unseal the other "standby" Vault servers as well to
achieve high availablity.

4.) Logout of the Vault server (ctrl+d) and check Vault's seal status from the
Jump host to verify you can interact with the Vault cluster from the Jump
host Vault CLI.
  $ vault status

You can now interact with Vault using any of the
CLI (https://www.vaultproject.io/docs/commands/index.html) or
API (https://www.vaultproject.io/api/index.html) commands.

Vault UI: http://${module.hashistack_lb.azurerm_public_ip_address[0]}:8200

########################################################################################
# WARNING - DO NOT DO THIS IN PRODUCTION!
# The Nomad nodes are in a public subnet with UI & SSH access open from the internet. 
########################################################################################


To start interacting with Vault, set your Vault token to authenticate requests.
We will use the "Initial Root Token" that was output from the 
`vault operator init` command.
  $ echo $${VAULT_ADDR} # Address you will be using to interact with Vault
  $ echo $${VAULT_TOKEN} # Vault Token being used to authenticate to Vault
  $ export VAULT_TOKEN=<ROOT_TOKEN> # If Vault token has not been set
Use the CLI to write and read a generic secret.
  $ vault kv put secret/cli foo=bar
  $ vault kv get secret/cli
Use the HTTP API with Consul DNS to write and read a generic secret with
Vault's KV secret engine.
If you're making HTTP API requests to Vault from the Jump host,
the below env var has been set for you.
  $ export VAULT_ADDR=http://vault.service.vault:8200
  $ curl \\
      -H \"X-Vault-Token: $${VAULT_TOKEN}\" \\
      -X POST \\
      -d '{\"data\": {\"foo\":\"bar\"}}' \\
      $${VAULT_ADDR}/v1/secret/data/api | jq '.' # Write a KV secret
  $ curl \\
      -H \"X-Vault-Token: $${VAULT_TOKEN}\" \\
      $${VAULT_ADDR}/v1/secret/data/api | jq '.' # Read a KV secret
}

# ------------------------------------------------------------------------------
# ${var.name} HashiStack Nomad - Azure
# ------------------------------------------------------------------------------
You can interact with Nomad using any of the CLI
(https://www.nomadproject.io/docs/commands/index.html) or API
(https://www.nomadproject.io/api/index.html) commands.

Nomad UI: http://${module.hashistack_lb.azurerm_public_ip_address[0]}:4646 (Public) 

########################################################################################
# WARNING - DO NOT DO THIS IN PRODUCTION!
# The Nomad nodes are in a public subnet with UI & SSH access open from the internet. 
########################################################################################

Use the CLI to retrieve Nomad servers & clients, then deploy a Redis Docker
container and check it's status.
  $ nomad server members # Check Nomad's server members
  $ nomad node-status # Check Nomad's client nodes
  $ nomad init # Create a skeletion job file to deploy a Redis Docker container
  $ nomad plan example.nomad # Run a nomad plan on the example job
  $ nomad run example.nomad # Run the example job
  $ nomad status # Check that the job is running
  $ nomad status example # Check job details
  $ nomad stop example # Stop the example job
  $ nomad status # Check that the job is stopped
Use the HTTP API to deploy a Redis Docker container.
  $ nomad run -output example.nomad > example.json # Convert job file to JSON
If you're making HTTP API requests to Nomad from the Jump host,
the below env var has been set for you.
  $ export NOMAD_ADDR=http://nomad.service.consul:4646
  $ curl \\
      -X POST \\
      -d @example.json \\
      $${NOMAD_ADDR}/v1/job/example/plan | jq '.' # Run a nomad plan
  $ curl \\
      -X POST \\
      -d @example.json \\
      $${NOMAD_ADDR}/v1/job/example | jq '.' # Run the example job
  $ curl \\
      -X GET \\
      $${NOMAD_ADDR}/v1/jobs | jq '.' # Check that the job is running
  $ curl \\
      -X GET \\
      $${NOMAD_ADDR}/v1/job/example | jq '.' # Check job details
  $ curl \\
      -X DELETE \\
      $${NOMAD_ADDR}/v1/job/example | jq '.' # Stop the example job
  $ curl \\
      -X GET \\
      $${NOMAD_ADDR}/v1/jobs | jq '.' # Check that the job is stopped
}
README
}
