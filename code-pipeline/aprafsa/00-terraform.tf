terraform {
  version = "0.11.7"

  backend "s3" {
    bucket         = "default-terraform-state-ap-southeast-1-015110552125"
    dynamodb_table = "default-terraform-state-ap-southeast-1-015110552125"
    key            = "ap-southeast-1/codebuild-docker-image/apr/aprafsa/terraform.tfstate"
    region         = "ap-southeast-1"
  }
}
