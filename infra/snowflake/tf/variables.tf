# -- infra/snowflake/tf/variables.tf
# ============================================================================
# Snowflake Module Variables
# ============================================================================

# variable "environment" {
#   description = "Environment name (devl, test, prod)"
#   type        = string
#   default     = "devl"
#
#   validation {
#     condition     = contains(["devl", "test", "prod"], var.environment)
#     error_message = "Environment must be devl, test, or prod."
#   }
# }

variable "project_code" {
  description = "Project code prefix for resource naming (e.g., snw-lkh)"
  type        = string
  default     = "snw"
}

# ============================================================================
# Snowflake Provider Variables
# ============================================================================

variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
  default     = ""
}

variable "snowflake_account_name" {
  description = "Snowflake account name"
  type        = string
  default     = ""
}

variable "snowflake_user" {
  description = "Snowflake user for Terraform operations"
  type        = string
  default     = ""
}

variable "db_provisioner_role" {
  description = "Snowflake role for database provisioning operations"
  type        = string
  default     = "PLATFORM_DB_ADMIN"
}

variable "warehouse_provisioner_role" {
  description = "Snowflake role for warehouse provisioning operations"
  type        = string
  default     = "WAREHOUSE_ADMIN"
}

variable "data_object_provisioner_role" {
  description = "Snowflake role for data object provisioning operations"
  type        = string
  default     = "DATA_OBJECT_ADMIN"
}

variable "ingest_object_provisioner_role" {
  description = "Snowflake role for ingest object provisioning operations"
  type        = string
  default     = "INGEST_ADMIN"
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse for Terraform operations"
  type        = string
  default     = "COMPUTE_WH"
}

# Note: For CI/CD, set SNOWFLAKE_PRIVATE_KEY environment variable directly
# The provider will pick it up automatically

# ============================================================================
# Configuration File Paths
# ============================================================================

variable "snowflake_config_path" {
  description = "Path to Snowflake config JSON file (relative to module)"
  type        = string
  default     = "../../../input-jsons/snowflake/config.json"
}


# variable "warehouse_config" {
#   description = "Warehouse configuration map"
#   type        = map(any)
# }

# variable "database_config" {
#   description = "Database configuration map"
#   type        = map(any)
#   default     = {}
# }

# variable "schema_config" {
#   description = "Schema configuration map"
#   type        = map(any)
#   default     = {}
# }

# variable "file_format_config" {
#   description = "File format configuration map"
#   type        = map(any)
#   default     = {}
# }

# variable "storage_integration_config" {
#   description = "Storage integration configuration map"
#   type        = map(any)
#   default     = {}
# }

# variable "stage_config" {
#   description = "Stage configuration map"
#   type        = map(any)
#   default     = {}
# }

# variable "table_config" {
#   description = "Table configuration map"
#   type        = map(any)
#   default     = {}
# }

# variable "snowpipe_config" {
#   description = "Snowpipe configuration map"
#   type        = map(any)
#   default     = {}
# }
