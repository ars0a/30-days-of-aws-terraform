terraform {
  backend "s3" {
    bucket = "terraform-day16-bucket-aditya"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}