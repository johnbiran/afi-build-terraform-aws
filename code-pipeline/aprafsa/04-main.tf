resource "aws_cloudwatch_log_group" "code_build_log_group" {
  name = "code_build_log_group"

  retention_in_days = "30"

  tags {
    Name          = "code_build_log_group"
    ProductDomain = "${local.product_domain}"
    Service       = "${local.service_name}"
    Environment   = "management"
    Description   = "LogGroup for ${local.service_name} codebuild docker image"
    ManagedBy     = "terraform"
  }
}

===================================================
================= Check codebuild =================
===================================================

resource "aws_codebuild_project" "codebuild_docker_image" {
  name         = "codebuild docker image project"
  description  = "codebuild for ${local.service_name} docker image"
  service_role = "${local.codebuild_role_arn}"

  environment {
    compute_type = "BUILD_GENERAL1_LARGE" # 15 GB memory, 8 vCPUs
    image        = "aws/codebuild/standard:2.0-1.9.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "GITHUB"
    location = "https://github.com/traveloka/afi-product-java"
    git_clone_depth = 1
  }

  tags {
    "Name"          = "${local.service_name}"
    "Description"   = "Build ${local.service_name} Docker Iamge"
    "Service"       = "${local.service_name}"
    "ProductDomain" = "${local.product_domain}"
    "Environment"   = "management"
    "ManagedBy"     = "terraform"
  }
}
