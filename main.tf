terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.43"
    }
    external = {
      source = "hashicorp/external"
      version = "~>2.3"
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
  
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "storage-state-file"
    key    = "build/terraform.tfstate"
    region = "us-east-1"
  }  
}

