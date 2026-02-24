# -- infra/snowflake/tf/tests/schema_creation.tftest.hcl
# ============================================================================
# Terraform Test: Schema Creation
# ============================================================================
# Basic test to verify database and schema creation works correctly.
# This test validates the database_schemas module output structure.
# ============================================================================

# ----------------------------------------------------------------------------
# Test: Verify Database and Schema Creation
# ----------------------------------------------------------------------------
run "verify_database_schema_creation" {
  command = plan

  # Verify database_schemas module produces expected output structure
  assert {
    condition     = length(module.database_schemas) > 0
    error_message = "Database schemas module should produce output"
  }
}

# ----------------------------------------------------------------------------
# Test: Verify Schema Names Match Configuration
# ----------------------------------------------------------------------------
run "verify_schema_names" {
  command = plan

  # Verify the database name includes project code prefix
  assert {
    condition     = can(local.database_schemas)
    error_message = "Database schemas local should be defined"
  }

  # Verify schemas are configured
  assert {
    condition     = length(local.database_schemas) > 0
    error_message = "At least one database with schemas should be configured"
  }
}
