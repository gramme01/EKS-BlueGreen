# Artifact bucket
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${local.name}-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

# CodeBuild projects
resource "aws_codebuild_project" "build" {
  name         = "${local.name}-build"
  service_role = aws_iam_role.codebuild_build.arn
  artifacts { type = "CODEPIPELINE" }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "ECR_REPO"
      value = aws_ecr_repository.app.repository_url
    }
    environment_variable {
      name  = "APP_NAME"
      value = local.name
    }
  }
  source { type = "CODEPIPELINE" }
  build_timeout = 30
}

resource "aws_codebuild_project" "deploy" {
  name         = "${local.name}-deploy"
  service_role = aws_iam_role.codebuild_deploy.arn
  artifacts { type = "CODEPIPELINE" }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
    environment_variable {
      name  = "CLUSTER_NAME"
      value = module.eks.cluster_name
    }
    environment_variable {
      name  = "HELM_CHART_PATH"
      value = "charts/bluegreen-api"
    }
    environment_variable {
      name  = "NAMESPACE"
      value = "default"
    }
    environment_variable {
      name  = "APP_NAME"
      value = local.name
    }
  }
  source { type = "CODEPIPELINE" }
  build_timeout = 30
}

# CodePipeline
resource "aws_codepipeline" "pipeline" {
  name     = "${local.name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn
  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceOutput"]
      configuration = {
        Owner                = var.github_owner
        Repo                 = var.github_repo
        Branch               = var.github_branch
        OAuthToken           = data.aws_ssm_parameter.github_token.value
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Container_Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Helm_Upgrade"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["BuildOutput"]
      configuration = {
        ProjectName = aws_codebuild_project.deploy.name
      }
    }
  }
}

# TODO: CloudWatch event (CodePipeline webhook) can be added as needed; recommend GitHub webhook configuration in console.
