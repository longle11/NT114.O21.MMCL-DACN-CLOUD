terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.43"
    }
    null = {
      source = "hashicorp/null"
      version = "~>3.2"
    }
    //used to download policies from github
    http = {
      source = "hashicorp/http"
      version = "~>3.4"
    }
  
    helm = {
      source = "hashicorp/helm"
      version = "~>2.13"
    }
  }
}

