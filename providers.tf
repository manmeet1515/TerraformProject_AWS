
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"] # this is ok because this is just a path and I am not going to commit my credentials into code repository
  profile                  = "CredentialsProfile"
}



