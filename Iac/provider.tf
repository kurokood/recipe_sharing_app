terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  backend "s3" {
    bucket         = "tf-state-store-121485"
    key            = "recipe-sharing-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock-121485"
  }
}
