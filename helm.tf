# Work from before 3/29 vvv 

provider "helm" {
  kubernetes {
    config_path = "./azurek8s"
    # config_path = "~/.kube/config"
  }
}

resource "helm_release" "vault-k8s" {
  name       = "vault-k8s"

  repository = "https://helm.releases.hashicorp.com/"
  chart      = "vault"

   values = [
     "${file("./vault-helm-values.yml")}"
   ]

  set {
    name  = "server.enterpriseLicense"
    value = "true"
  }

  set {
    name  = "certs.caBundle"
    value = "ca.crt"
  }

  set {
    name  = "certs.certName"
    value = "tls.crt"
  }

  set {
    name  = "certs.keyName"
    value = "tls.key"
  }

  depends_on = [
    aws_eks_cluster.example
  ]
}
