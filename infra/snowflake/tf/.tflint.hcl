# -- infra/snowflake/tf/.tflint.hcl
# ============================================================================
# TFLint Configuration
# ============================================================================

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Disable module pinned source rule - using main branch intentionally
# The tagged versions have provider declaration issues that need to be
# fixed in the upstream modules before pinning to specific versions.
rule "terraform_module_pinned_source" {
  enabled = false
}
