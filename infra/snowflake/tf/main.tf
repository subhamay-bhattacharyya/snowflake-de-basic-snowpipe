# -- infra/snowflake/tf/main.tf
# ============================================================================
# Snowflake Resources
# ============================================================================
#
# ┌─────────────────────────────────────────────────────────────┐
# │  1. WAREHOUSES                                              │
# ├─────────────────────────────────────────────────────────────┤
# │  Compute resources for query execution                      │
# └─────────────────────────────────────────────────────────────┘
#                             │
#                             ▼
# ┌─────────────────────────────────────────────────────────────┐
# │  2. DATABASES & SCHEMAS                                     │
# ├─────────────────────────────────────────────────────────────┤
# │  Logical containers for data organization                   │
# └─────────────────────────────────────────────────────────────┘
#                             │
#                             ▼
# ┌─────────────────────────────────────────────────────────────┐
# │  3. FILE FORMATS                                            │
# ├─────────────────────────────────────────────────────────────┤
# │  Define parsing rules for data files (CSV, JSON, etc.)      │
# └─────────────────────────────────────────────────────────────┘
#                             │
#                             ▼
# ┌─────────────────────────────────────────────────────────────┐
# │  4. INTERNAL STAGES                                         │
# ├─────────────────────────────────────────────────────────────┤
# │  Named storage locations for file staging                   │
# └─────────────────────────────────────────────────────────────┘
#                             │
#                             ▼
# ┌─────────────────────────────────────────────────────────────┐
# │  5. TABLES                                                  │
# ├─────────────────────────────────────────────────────────────┤
# │  Target tables for data ingestion                           │
# └─────────────────────────────────────────────────────────────┘
#                             │
#                             ▼
# ┌─────────────────────────────────────────────────────────────┐
# │  6. SNOWPIPES                                               │
# ├─────────────────────────────────────────────────────────────┤
# │  Auto-ingest pipelines for continuous data loading          │
# └─────────────────────────────────────────────────────────────┘
#
# ============================================================================

# ----------------------------------------------------------------------------
# 1. Warehouses
# ----------------------------------------------------------------------------
module "warehouse" {
  source = "github.com/subhamay-bhattacharyya-tf/terraform-snowflake-warehouse?ref=v2.0.0"

  providers = {
    snowflake = snowflake.warehouse_provisioner
  }

  warehouse_configs = local.warehouses
}

# ----------------------------------------------------------------------------
# 2. Databases and Schemas
# ----------------------------------------------------------------------------
module "database_schemas" {
  source = "github.com/subhamay-bhattacharyya-tf/terraform-snowflake-database-schema?ref=v1.2.0"

  providers = {
    snowflake = snowflake.db_provisioner
  }

  database_configs = local.database_schemas
}

# ----------------------------------------------------------------------------
# 3. File Formats
# ----------------------------------------------------------------------------
module "file_formats" {
  source = "github.com/subhamay-bhattacharyya-tf/terraform-snowflake-file-format?ref=v1.2.0"

  providers = {
    snowflake = snowflake.data_object_provisioner
  }

  file_format_configs = local.file_formats

  depends_on = [module.database_schemas]
}

# ----------------------------------------------------------------------------
# 4. Internal Stage
# ----------------------------------------------------------------------------
module "stage" {
  source = "github.com/subhamay-bhattacharyya-tf/terraform-snowflake-stage?ref=v1.1.0"

  providers = {
    snowflake = snowflake.ingest_object_provisioner
  }

  stage_configs = local.stages

  depends_on = [module.database_schemas]
}

# ----------------------------------------------------------------------------
# 5. Tables
# ----------------------------------------------------------------------------
module "table" {
  source = "github.com/subhamay-bhattacharyya-tf/terraform-snowflake-table?ref=v2.0.0"

  providers = {
    snowflake = snowflake.data_object_provisioner
  }

  table_configs = local.tables

  depends_on = [module.database_schemas]
}

# ----------------------------------------------------------------------------
# 5.1 Table Grants
# ----------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "table_grants" {
  for_each = local.tables

  account_role_name = var.ingest_object_provisioner_role
  privileges        = ["INSERT", "SELECT"]

  on_schema_object {
    object_type = "TABLE"
    object_name = "\"${each.value.database}\".\"${each.value.schema}\".\"${each.value.name}\""
  }

  depends_on = [module.table]
}

# ----------------------------------------------------------------------------
# 6. Snowpipes
# ----------------------------------------------------------------------------
module "pipe" {
  source = "github.com/subhamay-bhattacharyya-tf/terraform-snowflake-pipe?ref=v2.0.0"

  providers = {
    snowflake = snowflake.ingest_object_provisioner
  }

  pipe_configs = local.snowpipes

  depends_on = [module.table]
}
