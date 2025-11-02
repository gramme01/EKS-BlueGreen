resource "aws_ssm_parameter" "app_env_version" {
  name  = "/${local.name}/APP_VERSION"
  type  = "String"
  value = "0.1.0"
}

# TODO: Store GitHub OAuth token in SSM Parameter Store beforehand
# aws ssm put-parameter --name "/ci/github/token" --type SecureString --value "ghp_xxx"
data "aws_ssm_parameter" "github_token" { name = var.github_oauth_token_ssm }
