provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "production"
      Project     = "vaultwarden-serverless"
    }
  }
}

# Ensure NEON_API_KEY environment variable is set
terraform {
  required_providers {
    neon = {
      source = "kislerdm/neon"
    }
  }
}

provider "neon" {
  api_key = var.neon_api_key
}
