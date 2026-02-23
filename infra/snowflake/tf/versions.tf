# -- infra/snowflake/tf/versions.tf
# ============================================================================
# Terraform Version and Provider Requirements
# ============================================================================

terraform {
  required_version = ">= 1.14.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = ">= 1.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}