# Terraform configration
terraform {
  required_version = ">=1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.73"
    }
  }
}

# Provider
provider "aws" {
  profile = "terraform_private"
  region  = "ap-northeast-1"
}

# Variables
# variable "project" {
#   type = string
# }

# variable "environment" {
#   type = string
# }