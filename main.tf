terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.4.0"
    }    
    helm = {
      source = "hashicorp/helm"
      version = "2.10.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    vault = {
      source = "hashicorp/vault"
      version = "3.15.2"
    }
  }
}

resource "random_pet" "example" {

}
