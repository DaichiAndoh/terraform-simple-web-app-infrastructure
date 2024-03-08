# ==================================
# Terraform
# ==================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# ==================================
# Provider
# ==================================
provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
}

# ==================================
# Variables
# ==================================
variable "project" {
  type = string
}
variable "user" {
  type = string
}
