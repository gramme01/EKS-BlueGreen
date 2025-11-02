variable "project_name" {
  type    = string
  default = "eks-bluegreen-demo"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "github_owner" { type = string } # e.g., "your-gh-user"

variable "github_repo" { type = string } # e.g., "eks-bluegreen-demo"

variable "github_branch" {
  type    = string
  default = "main"
}

variable "github_oauth_token_ssm" {
  type    = string
  default = "/ci/github/token"
} # GH PAT hosted in SSM Parameter Store

variable "email_for_alerts" { type = string } # SNS email for alerts (optional)
