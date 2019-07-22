resource "aws_s3_bucket" "input_bucket" {
  bucket = "afi-codebuild"
  acl    = "private"
}

resource "aws_s3_bucket" "source_bucket" {
  bucket = "afi-appbin"
  acl    = "private"
}

/*
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:CreateRepository"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
*/

resource "aws_iam_role_policy" "codepipeline_policy" {
  source = "github.com/traveloka/terraform-aws-bake-ami.git?ref=v2.2.4"
  
  name = "codepipeline_policy"
  role = "${aws_iam_role.codepipeline_role}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning"
      ],
      "Resource": [
        "${aws_s3_bucket.input_bucket.arn}",
        "${aws_s3_bucket.input_bucket.arn}/*",
        "${aws_s3_bucket.source_bucket.arn}",
        "${aws_s3_bucket.source_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codebuild_project" "afi_codebuild_project" {
  name = "afi-codebuild_project"
  description = "afi codebuild project"
  build_timeout = "5"
  service_role = "${aws_iam_role.codepipeline_role.id}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type = "S3"
    location = "${aws_s3_bucket.input_bucket.bucket}"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "ap-southeast-1"
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "517530806209.dkr.ecr.ap-southeast-1.amazonaws.com/aprafsa-docker-image"
    }

     environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  source {
    type            = "S3"
    location        = "afi-codebuild/aprafsa-codebuild.zip"
  }

} 


# https://github.com/traveloka/terraform-aws-bake-ami/blob/master/main.tf#L53
# Refer to this aprafsa codebuild terraform

resource "aws_codepipeline" "afi_docker_codepipeline" {
  name     = "afi_docker_codepipeline"
  role_arn = "${var.codepipeline_role_arn}"

  artifact_store {
    location = "${var.codepipeline_artifact_bucket}"
    type     = "S3"
  }

  stage {
    name = "Build"

    action {
      name             = "Bake"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild" 
      version          = "1"

      configuration {
        ProjectName = "${local.afi_codebuild_project}"
      }

      run_order = "1"
    }
  } 
  /*
  tags {
    "Name"          = "${local.pipeline_name}"
    "Description"   = "${var.service_name} AMI Baking Pipeline"
    "Service"       = "${var.service_name}"
    "ProductDomain" = "${var.product_domain}"
    "Environment"   = "management"
    "ManagedBy"     = "terraform"
  }
  */
}

 