terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source = "integrations/github"
      version = "6.2.2"
    }
  }
}


provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"] # this is ok because this is just a path and I am not going to commit my credentials into code repository
  profile                  = "CredentialsProfile"
}

provider "github" {
  token = var.github_token
}

