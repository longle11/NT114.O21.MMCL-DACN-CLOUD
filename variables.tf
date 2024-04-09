// Main Variables

variable "aws_region" {
  description = "Region in which aws resources to be created"
  type = string
  default = "us-east-1"
}

variable "aws_environment" {
  description = "Aws Environment"
  type = string
  default = "dev"
}


// EC2 Instace Variables
variable "aws_instance_type" {
  description = "Aws Instance Type"
  type = string
  default = "t3.medium"
}

variable "aws_key_pair" {
  description = "Aws key pair which needs to be associated with ec2 instance"
  type = string
  default = "keypair"
}

// VPC Variables
variable "vpc_name" {
  description = "VPC Name"
  type = string
  default = "myvpc"
}

variable "vpc_cidr" {
    description = "VPC CIDR Block"
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}

variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type = list(string)
  default = [ "10.0.101.0/24", "10.0.102.0/24" ]
}

variable "vpc_availability_zones" {
  description = "VPC Availability Zones"
  type = list(string)
  default = [ "us-east-1a", "us-east-1b" ]
}

variable "vpc_enable_nat_gateway" {
  description = "VPC Enable Nat Gateway"
  type = bool
  default = true
}
variable "vpc_single_nat_gateway" {
  description = "VPC Single Nat Gateway"
  type = bool
  default = true
}


// EKS Variable
variable "eks_cluster_name" {
  description = "EKS Cluster Name"
  type = string
  default = "eksclusterproject"
}

variable "eks_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes pod and service IP addresses"
  type = string
  default = "172.16.0.0/16"
}

# variable "eks_cluster_version" {
  
# }

variable "eks_endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type = bool
  default = false
}

variable "eks_endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type = bool
  default = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


# Exact oidc provider information
locals {
  aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", aws_iam_openid_connect_provider.oidc_provider.arn), 1)
}