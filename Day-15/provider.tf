terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.primary_region
  alias = "primary"
}

provider "aws" {
  region = var.secondary_region
  alias = "secondary"
}