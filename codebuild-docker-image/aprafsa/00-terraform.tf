terraform { 

  backend "s3" {
    bucket         = "apr-terraform-state-ap-southeast-1-517530806209"
    dynamodb_table = "apr-terraform-state-ap-southeast-1-517530806209"
    key            = "ap-southeast-1/codebuild-docker-image/aprafsa/terraform.tfstate"
    region         = "ap-southeast-1"
  }
} 