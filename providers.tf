provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ShopEase"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "satya"
    }
  }
}
