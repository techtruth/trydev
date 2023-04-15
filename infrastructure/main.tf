terraform {
  required_version = ">= 1.4.5"

  backend "s3" {
    bucket         = "trydev.terraform-state"
    key            = "trydev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
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
  region = "us-east-1"
}
