# CodeBuild build role
resource "aws_iam_role" "codebuild_build" {
  name = "${local.name}-codebuild-build"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "codebuild.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "codebuild_build" {
  name = "${local.name}-codebuild-build"
  role = aws_iam_role.codebuild_build.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["logs:*", "cloudwatch:*"], Resource = "*" },
      { Effect = "Allow", Action = ["ecr:GetAuthorizationToken"], Resource = "*" },
      { Effect = "Allow", Action = ["ecr:BatchCheckLayerAvailability", "ecr:CompleteLayerUpload", "ecr:UploadLayerPart", "ecr:InitiateLayerUpload", "ecr:PutImage", "ecr:BatchGetImage"], Resource = aws_ecr_repository.app.arn },
      { Effect = "Allow", Action = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParameterHistory"], Resource = "*" }
    ]
  })
}

# CodeBuild deploy role (kubectl/helm to EKS)
resource "aws_iam_role" "codebuild_deploy" {
  name = "${local.name}-codebuild-deploy"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "codebuild.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "codebuild_deploy" {
  name = "${local.name}-codebuild-deploy"
  role = aws_iam_role.codebuild_deploy.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["logs:*", "cloudwatch:*"], Resource = "*" },
      { Effect = "Allow", Action = ["eks:DescribeCluster"], Resource = "*" },
      { Effect = "Allow", Action = ["ssm:GetParameter", "ssm:GetParameters"], Resource = "*" }
    ]
  })
}

# CodePipeline role
resource "aws_iam_role" "codepipeline" {
  name = "${local.name}-codepipeline"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "codepipeline.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "${local.name}-codepipeline"
  role = aws_iam_role.codepipeline.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"], Resource = "*" },
      { Effect = "Allow", Action = ["s3:*", "kms:*"], Resource = "*" },
      { Effect = "Allow", Action = ["iam:PassRole"], Resource = [aws_iam_role.codebuild_build.arn, aws_iam_role.codebuild_deploy.arn] }
    ]
  })
}
