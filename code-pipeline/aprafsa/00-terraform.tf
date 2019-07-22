terraform {
  version = "0.11.7"

  backend "s3" {
    bucket         = "afi-build-terraform-state" 
    key            = "afi-build-terraform-state/terraform.tfstate"
    region         = "ap-southeast-1"
  }
}
