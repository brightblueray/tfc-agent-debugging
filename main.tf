terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28"
    }
    hcp = {
      source = "hashicorp/hcp"
    }
    azure = {
      source = "hashicorp/azure"
    }
  }

  cloud {
    organization = "[ORG]"
    workspaces {
      name = "[WORKSPACE NAME]"
    }
  }
}

provider "hcp" {}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Purpose     = ""
      Owner       = "rryjewski"
    }
  }
}
