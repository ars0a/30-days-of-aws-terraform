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
  region = "us-east-1"
  alias = "primary"
}

provider "aws" {
  region = "us-west-2"
  alias = "secondary"
}