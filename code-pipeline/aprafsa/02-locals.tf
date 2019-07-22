locals {
  product_domain = "apr"
  service_name   = "aprafsa"

  terraform_remote_state_backend              = "s3"
  terraform_remote_state_bucket               = "afi-build-terraform-state"
  terraform_remote_state_bucket_region        = "ap-southeast-1"
  
}
