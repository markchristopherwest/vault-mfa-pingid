provider "vault" {
  # Configuration options
  address = hcp_vault_cluster.example.vault_public_endpoint_url
  token = hcp_vault_cluster_admin_token.example.token
  skip_child_token = true
  skip_get_vault_version = true
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/namespace#nested-namespaces
variable "child_namespaces" {
  type = set(string)
  default = [
    "child_0",
    "child_1",
    "child_2",
  ]
}

resource "vault_namespace" "children" {
  for_each  = var.child_namespaces
  namespace = "admin"
  path      = each.key
}

resource "vault_mount" "children" {
  for_each  = vault_namespace.children
  namespace = each.value.path_fq
  path      = "secrets"
  type      = "kv"
  options = {
    version = "1"
  }
}

resource "vault_generic_secret" "children" {
  for_each  = vault_mount.children
  namespace = each.value.namespace
  path      = "${each.value.path}/secret"
  data_json = jsonencode(
    {
      "ns" = each.key
    }
  )
}


# There is a bug in the provider documentation i.e.:
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_mfa_pingid#example-usage
resource "vault_identity_mfa_pingid" "example" {
  namespace = "admin"
  settings_file_base64 = base64encode(file("./../../../Downloads/pingid.properties"))
#   policies = [ vault_policy.example.name]
#   mount_accessor = vault_auth_backend.example.path

}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend#example-usage
resource "vault_jwt_auth_backend" "example" {
  for_each  = vault_mount.children
  namespace = each.value.namespace
    description         = "Demonstration of the Terraform JWT auth backend"
    path                = "jwt"
    oidc_discovery_url  = "https://idpxnyl3m.pingidentity.com/pingid"
    bound_issuer        = "https://idpxnyl3m.pingidentity.com/pingid"
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend_role#example-usage
resource "vault_jwt_auth_backend_role" "example" {
  for_each  = vault_mount.children
  namespace = each.value.namespace
  backend         = vault_jwt_auth_backend.example[each.key].path
  role_name       = "test-role"
  token_policies  = ["default", "dev", "prod"]

  bound_audiences = ["https://myco.test"]
  bound_claims = {
    color = "red,green,blue"
  }
  user_claim      = "https://vault/user"
  role_type       = "jwt"
}

# https://developer.hashicorp.com/vault/docs/enterprise/mfa/mfa-pingid#configuration
resource "vault_policy" "example" {
  for_each  = vault_mount.children
  namespace = each.value.namespace
  name = "ping-policy"

  policy = <<EOT
path "secret/foo" {
  capabilities = ["read"]
  mfa_methods  = ["ping"]
}
EOT
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount#example-usage
resource "vault_mount" "kvv1" {
  namespace = "admin"
  path        = "secret"
  type        = "kv"
  options     = { version = "1" }
  description = "KV Version 1 secret engine mount"
}

# https://developer.hashicorp.com/vault/docs/enterprise/mfa/mfa-pingid#configuration
resource "vault_kv_secret" "foo" {
  namespace = vault_mount.kvv1.namespace
  path = "${vault_mount.kvv1.path}/foo"
  data_json = jsonencode(
    {
    "data": "Wanna Get Away"
    }
  )
}
