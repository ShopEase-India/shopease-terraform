locals {
  project     = "shopease"
  environment = var.environment

  commom_tags = {
    Project     = "ShopEase"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Platform-Team"
  }
  vpc_name = "${local.project}-${local.environment}-vpc"

  public_subnet_1_name = "${local.project}-public-subnet-az1"
  public_subnet_2_name = "${local.project}-public-subnet-az2"

  igw_name = "${local.project}-${local.environment}-igw"
}