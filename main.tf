terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.43"
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

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
  
  //add s3 bucket
  backend "s3" {
    bucket = "storage-state-file"
    key    = "build/terraform.tfstate"
    region = "us-east-1"
  }  
}

