provider "kubernetes" {
  # Configuration options
}

# resource "kubernetes_secret" "vault_license" {
#   metadata {
#     name = "vault_license"
#   }

#   data = file("./../../../Downloads/vault.hclic")
#   depends_on = [
#     aws_eks_cluster.example
#   ]

# }

# module "tls_automagically" {
#   source            = "github.com/markchristopherwest/terraform-tls-automagically"
#   product_manifest  = local.product_manifest
#   path_tls          = "${path.module}/tls"
#   owner             = "mark"
#   organization_name = "Beyond Corp"
#   ca_common_name    = "vault.local"

#   target_regions = [ "us-west-1" ]

#   tags = local.standard_tags
# }

# resource "kubernetes_secret" "cert_ca" {
#   metadata {
#     name = "vault_ca"
#   }

#   data = file("./../../../Downloads/ca.pem")
#   depends_on = [
#     eks_cluster.example
#   ]

# }

# resource "kubernetes_secret" "cert_server" {
#   metadata {
#     name = "vault_cert"
#   }

#   data = file("./../../../Downloads/vault.pem")
#   depends_on = [
#     aws_eks_cluster.example
#   ]

# }