terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.15.2"
    }
  }
}

provider "vault" {
  # Configuration options
  address = hcp_vault_cluster.example.vault_public_endpoint_url
  token = hcp_vault_cluster_admin_token.example.token
  skip_child_token = true
  skip_get_vault_version = true
}

# resource "vault_auth_backend" "example" {
#   namespace = "admin"
#   type = "userpass"

#   tune {
#     max_lease_ttl      = "25h"
#     listing_visibility = "unauth"
#   }
# }

# resource "vault_mount" "kvv1" {
#   path        = "secret"
#   type        = "kv"
#   options     = { version = "1" }
#   description = "KV Version 1 secret engine mount"
# }

# resource "vault_kv_secret" "foo" {
#   path = "${vault_mount.kvv1.path}/foo"
#   data_json = jsonencode(
#     {
#     "data": "Wanna Get Away"
#     }
#   )
# }


# # There is a bug in the provider documentation i.e.:
# # https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_mfa_pingid#example-usage
# resource "vault_identity_mfa_pingid" "example" {
#   settings_file_base64 = base64encode(file("./../../../Downloads/pingid.properties"))
# #   policies = [ vault_policy.example.name]
# #   mount_accessor = vault_auth_backend.example.path

# }

# resource "vault_policy" "example" {
#   name = "ping-policy"

#   policy = <<EOT
# path "secret/foo" {
#   capabilities = ["read"]
#   mfa_methods  = ["ping"]
# }
# EOT
# }
