# https://registry.terraform.io/providers/hashicorp/hcp/latest/docs/resources/vault_cluster#example-usage
resource "hcp_hvn" "example" {
  hvn_id         = "hvn-${random_pet.example.id}"
  cloud_provider = "aws"
  region         = "us-west-2"
  cidr_block     = "172.25.16.0/20"
}

resource "hcp_vault_cluster" "example" {
  cluster_id = random_pet.example.id
  hvn_id     = hcp_hvn.example.hvn_id
  tier       = "standard_large"
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "example" {
  cluster_id = random_pet.example.id
}
