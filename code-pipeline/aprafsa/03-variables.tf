variable "service_name" {
  type        = "string"
  description = "the name of the service"
}

variable "product_domain" {
  type        = "string"
  description = "the owner of this pipeline (e.g. team). This is used mostly for adding tags to resources"
}
 
variable "buildspec" {
  type        = "string"
  description = "the buildspec for the CodeBuild project"
}

variable "codepipeline_artifact_bucket" {
  type        = "string"
  description = "An S3 bucket to be used as CodePipeline's artifact bucket"
}

variable "codepipeline_role_arn" {
  type        = "string"
  description = "The role arn to be assumed by the codepipeline"
}
 
 