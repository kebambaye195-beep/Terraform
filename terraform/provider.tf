terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region                  = var.region
  shared_credentials_files = ["~/.aws/credentials"] # utile si tu testes en local
  profile                 = "default"

  # Si tu veux utiliser les variables d'environnement (depuis Jenkins ou CLI)
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

