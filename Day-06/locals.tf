locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "30DaysOfTerraform"
  }
}
