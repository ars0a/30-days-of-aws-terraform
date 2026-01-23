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
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {                                     #updated after first tf apply
    Name        = "day3-vpc"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# create a private s3 bucket
resource "random_id" "suffix" {
  byte_length = 4
}
resource "aws_s3_bucket" "example" {
  bucket = "aditya-tf-day3-${random_id.suffix.hex}"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
