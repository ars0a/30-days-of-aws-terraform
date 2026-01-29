module "vpc" {
  source = "./modules/vpc"

  cidr_block = var.vpc_cidr
  tags       = local.common_tags
}
