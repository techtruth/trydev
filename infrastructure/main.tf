terraform {
  required_version = "<= 1.3.4"

  backend "s3" {
    bucket         = "infrastructure-terraform"
    key            = "${var.deployment_tag}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.39.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.12.0"
    }
  }
}

provider "github" {
  token = var.github_pat
  owner = "techtruth"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
