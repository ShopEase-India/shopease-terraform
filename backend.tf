terraform {

  backend "s3" {

    bucket = "shopease-dev-terraform-state"

    key = "dev/eks/terraform.tfstate"

    region = "ap-south-2"

    use_lockfile = true
    
    encrypt = true

  }

}