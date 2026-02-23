# Snowflake Data Engineering - Basic Snowpipe

![Built with Kiro](https://img.shields.io/badge/Built_with-Kiro-8845f4?logo=robot&logoColor=white)&nbsp;![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya/snowflake-de-basic-snowpipe)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya/snowflake-de-basic-snowpipe)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya/snowflake-de-basic-snowpipe)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya/snowflake-de-basic-snowpipe)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya/snowflake-de-basic-snowpipe)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya/snowflake-de-basic-snowpipe)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya/snowflake-de-basic-snowpipe)&nbsp;![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/54427a0d24881d168aef1f7acdcff3e0/raw/snowflake-de-basic-snowpipe.json?)

A Snowflake data engineering project demonstrating automated data ingestion using Snowpipe, Infrastructure as Code (Terraform), and role-based access control governance.

## Overview

This repository implements a complete Snowflake data pipeline with:

- **Infrastructure as Code**: Terraform configurations for Snowflake resources
- **Automated Ingestion**: Snowpipe for continuous data loading
- **Role-Based Governance**: Separate provisioner roles for different object types
- **JSON-Driven Configuration**: External configuration files for easy customization
- **Modular Architecture**: Reusable Terraform modules for each resource type

## Repository Structure

```
.
├── infra/                              # Infrastructure as Code
│   └── snowflake/tf/                   # Snowflake Terraform configuration
│       ├── main.tf                     # Resource orchestration (modules)
│       ├── locals.tf                   # Configuration parsing from JSON
│       ├── variables.tf                # Input variables
│       ├── outputs.tf                  # Module outputs
│       ├── versions.tf                 # Terraform & provider versions
│       ├── backend.tf                  # Terraform backend configuration
│       ├── providers-snowflake.tf      # Snowflake provider with role aliases
│       ├── terraform.tfvars            # Variable values
│       └── templates/                  # Template files
│           └── snowpipe-copy-statement.tpl
├── input-jsons/                        # Configuration files
│   └── snowflake/
│       └── config.json                 # Snowflake resource configuration
├── sample-data/                        # Sample CSV data files
│   ├── sales01.csv
│   └── sales02.csv
├── .github/
│   └── workflows/                      # GitHub Actions CI/CD
│       ├── ci.yaml                     # Continuous integration
│       ├── terraform-deploy.yaml       # Terraform deployment
│       └── terraform-destroy.yaml      # Terraform destroy
├── .devcontainer/                      # Dev container configuration
├── utils/                              # Utility scripts
└── README.md
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  1. WAREHOUSES                                              │
├─────────────────────────────────────────────────────────────┤
│  Compute resources for query execution                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  2. DATABASES & SCHEMAS                                     │
├─────────────────────────────────────────────────────────────┤
│  Logical containers for data organization                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  3. FILE FORMATS                                            │
├─────────────────────────────────────────────────────────────┤
│  Define parsing rules for data files (CSV, JSON, etc.)      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  4. INTERNAL STAGES                                         │
├─────────────────────────────────────────────────────────────┤
│  Named storage locations for file staging                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  5. TABLES                                                  │
├─────────────────────────────────────────────────────────────┤
│  Target tables for data ingestion                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  6. SNOWPIPES                                               │
├─────────────────────────────────────────────────────────────┤
│  Auto-ingest pipelines for continuous data loading          │
└─────────────────────────────────────────────────────────────┘
```

## Security & Governance

### Role-Based Access Control (RBAC)

This project implements a **least-privilege governance model** using dedicated admin roles for different Snowflake object types. Each role has specific permissions to create and manage only the objects within its domain, following Snowflake's recommended security best practices.

#### Admin Roles Overview

| Role | Purpose | Objects Managed | Provider Alias |
|------|---------|-----------------|----------------|
| `WAREHOUSE_ADMIN` | Warehouse lifecycle management | Warehouses | `snowflake.warehouse_provisioner` |
| `PLATFORM_DB_ADMIN` | Database & schema administration | Databases, Schemas | `snowflake.db_provisioner` |
| `DATA_OBJECT_ADMIN` | Data object administration | File Formats, Tables | `snowflake.data_object_provisioner` |
| `INGEST_ADMIN` | Ingestion pipeline administration | Stages, Snowpipes | `snowflake.ingest_object_provisioner` |

#### Role Hierarchy & Responsibilities

```
                                    ACCOUNTADMIN
                                         │
                          ┌──────────────┼──────────────┐
                          │              │              │
                          ▼              ▼              ▼
                     SYSADMIN      SECURITYADMIN    USERADMIN
                          │
      ┌───────────────────┼───────────────────┬───────────────────┐
      │                   │                   │                   │
      ▼                   ▼                   ▼                   ▼
WAREHOUSE_ADMIN    PLATFORM_DB_ADMIN   DATA_OBJECT_ADMIN    INGEST_ADMIN
      │                   │                   │                   │
      ▼                   ▼                   ▼                   ▼
 Warehouses          Databases          File Formats          Stages
                     Schemas            Tables                Snowpipes
```

#### Role Details

##### WAREHOUSE_ADMIN
- **Purpose**: Manages compute resources for query execution
- **Privileges**:
  - `CREATE WAREHOUSE` on account
  - `MODIFY`, `MONITOR`, `OPERATE` on warehouses
- **Use Case**: Controls warehouse sizing, auto-suspend, scaling policies

##### PLATFORM_DB_ADMIN
- **Purpose**: Manages logical data containers
- **Privileges**:
  - `CREATE DATABASE` on account
  - `CREATE SCHEMA` on databases
  - `USAGE` on databases and schemas
- **Use Case**: Creates and organizes databases/schemas for different data domains

##### DATA_OBJECT_ADMIN
- **Purpose**: Manages data storage objects
- **Privileges**:
  - `CREATE FILE FORMAT` on schemas
  - `CREATE TABLE` on schemas
  - `USAGE` on databases and schemas
- **Use Case**: Defines data structures, file parsing rules, table schemas

##### INGEST_ADMIN
- **Purpose**: Manages data ingestion pipelines
- **Privileges**:
  - `CREATE STAGE` on schemas
  - `CREATE PIPE` on schemas
  - `READ`, `WRITE` on stages
  - `INSERT`, `SELECT` on tables (granted by DATA_OBJECT_ADMIN)
- **Use Case**: Sets up automated data loading from stages to tables

#### How Role Separation Works

1. **Terraform Provider Aliases**: Each admin role has a dedicated Snowflake provider alias configured in `providers-snowflake.tf`:

```hcl
# Warehouse operations
provider "snowflake" {
  alias = "warehouse_provisioner"
  role  = var.warehouse_provisioner_role  # WAREHOUSE_ADMIN
}

# Database/Schema operations
provider "snowflake" {
  alias = "db_provisioner"
  role  = var.db_provisioner_role  # PLATFORM_DB_ADMIN
}

# File Format/Table operations
provider "snowflake" {
  alias = "data_object_provisioner"
  role  = var.data_object_provisioner_role  # DATA_OBJECT_ADMIN
}

# Stage/Pipe operations
provider "snowflake" {
  alias = "ingest_object_provisioner"
  role  = var.ingest_object_provisioner_role  # INGEST_ADMIN
}
```

2. **Module Provider Assignment**: Each Terraform module uses the appropriate provider based on the objects it manages:

```hcl
# Warehouses managed by WAREHOUSE_ADMIN
module "warehouse" {
  providers = { snowflake = snowflake.warehouse_provisioner }
}

# Databases/Schemas managed by PLATFORM_DB_ADMIN
module "database_schemas" {
  providers = { snowflake = snowflake.db_provisioner }
}

# File Formats/Tables managed by DATA_OBJECT_ADMIN
module "file_formats" {
  providers = { snowflake = snowflake.data_object_provisioner }
}
module "table" {
  providers = { snowflake = snowflake.data_object_provisioner }
}

# Stages/Pipes managed by INGEST_ADMIN
module "stage" {
  providers = { snowflake = snowflake.ingest_object_provisioner }
}
module "pipe" {
  providers = { snowflake = snowflake.ingest_object_provisioner }
}
```

3. **Cross-Role Grants**: When objects created by one role need to be accessed by another role, explicit grants are configured:

```hcl
# Tables created by DATA_OBJECT_ADMIN need INSERT/SELECT granted to INGEST_ADMIN
# This allows Snowpipes (owned by INGEST_ADMIN) to load data into tables
resource "snowflake_grant_privileges_to_account_role" "table_grants" {
  account_role_name = var.ingest_object_provisioner_role  # INGEST_ADMIN
  privileges        = ["INSERT", "SELECT"]
  on_schema_object {
    object_type = "TABLE"
    object_name = "\"DATABASE\".\"SCHEMA\".\"TABLE\""
  }
}
```

#### Benefits of Role Separation

| Benefit | Description |
|---------|-------------|
| **Least Privilege** | Each role only has permissions for its specific domain |
| **Audit Trail** | Clear ownership and accountability for each object type |
| **Separation of Duties** | Different teams can manage different object types |
| **Blast Radius Reduction** | Compromised credentials have limited impact |
| **Compliance Ready** | Easier to demonstrate access controls for SOC2, HIPAA, etc. |
| **Operational Safety** | Prevents accidental modifications to unrelated objects |

#### Setting Up Admin Roles

Run the following SQL as `ACCOUNTADMIN` to create the admin roles:

```sql
-- ============================================================================
-- Create Admin Roles for Snowflake Governance
-- ============================================================================

-- 1. Create the admin roles
CREATE ROLE IF NOT EXISTS WAREHOUSE_ADMIN
  COMMENT = 'Manages warehouse lifecycle - create, modify, monitor';

CREATE ROLE IF NOT EXISTS PLATFORM_DB_ADMIN
  COMMENT = 'Manages databases and schemas';

CREATE ROLE IF NOT EXISTS DATA_OBJECT_ADMIN
  COMMENT = 'Manages file formats and tables';

CREATE ROLE IF NOT EXISTS INGEST_ADMIN
  COMMENT = 'Manages stages and snowpipes for data ingestion';

-- 2. Grant account-level privileges
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE WAREHOUSE_ADMIN;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE PLATFORM_DB_ADMIN;

-- 3. Set up role hierarchy (roles inherit from SYSADMIN)
GRANT ROLE WAREHOUSE_ADMIN TO ROLE SYSADMIN;
GRANT ROLE PLATFORM_DB_ADMIN TO ROLE SYSADMIN;
GRANT ROLE DATA_OBJECT_ADMIN TO ROLE SYSADMIN;
GRANT ROLE INGEST_ADMIN TO ROLE SYSADMIN;

-- 4. Grant roles to service account (for Terraform)
GRANT ROLE WAREHOUSE_ADMIN TO USER TF_SERVICE_ACCOUNT;
GRANT ROLE PLATFORM_DB_ADMIN TO USER TF_SERVICE_ACCOUNT;
GRANT ROLE DATA_OBJECT_ADMIN TO USER TF_SERVICE_ACCOUNT;
GRANT ROLE INGEST_ADMIN TO USER TF_SERVICE_ACCOUNT;

-- 5. Grant warehouse usage to all admin roles
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE WAREHOUSE_ADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE PLATFORM_DB_ADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DATA_OBJECT_ADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE INGEST_ADMIN;
```

#### Setting Up Analyst Role (Read-Only)

Run the following SQL as `ACCOUNTADMIN` to create a read-only analyst role:

```sql
-- ============================================================================
-- Create Analyst Role for Read-Only Access
-- ============================================================================

-- 1. Create the analyst role
CREATE ROLE IF NOT EXISTS ANALYST
  COMMENT = 'Read-only access to query tables and views';

-- 2. Set up role hierarchy (ANALYST reports to SYSADMIN)
GRANT ROLE ANALYST TO ROLE SYSADMIN;

-- 3. Grant warehouse usage for query execution
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST;

-- 4. Grant database and schema usage (read-only)
GRANT USAGE ON DATABASE <DATABASE_NAME> TO ROLE ANALYST;
GRANT USAGE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE ANALYST;

-- 5. Grant SELECT on all existing tables in schema
GRANT SELECT ON ALL TABLES IN SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE ANALYST;

-- 6. Grant SELECT on all existing views in schema
GRANT SELECT ON ALL VIEWS IN SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE ANALYST;

-- 7. Grant SELECT on future tables (auto-grant for new tables)
GRANT SELECT ON FUTURE TABLES IN SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE ANALYST;

-- 8. Grant SELECT on future views (auto-grant for new views)
GRANT SELECT ON FUTURE VIEWS IN SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE ANALYST;

-- 9. Grant role to analyst users
GRANT ROLE ANALYST TO USER <ANALYST_USERNAME>;
```

#### Post-Database Creation Grants

After databases and schemas are created by `PLATFORM_DB_ADMIN`, run these grants:

```sql
-- Grant schema privileges to DATA_OBJECT_ADMIN
GRANT USAGE ON DATABASE <DATABASE_NAME> TO ROLE DATA_OBJECT_ADMIN;
GRANT USAGE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE DATA_OBJECT_ADMIN;
GRANT CREATE FILE FORMAT ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE DATA_OBJECT_ADMIN;
GRANT CREATE TABLE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE DATA_OBJECT_ADMIN;

-- Grant schema privileges to INGEST_ADMIN
GRANT USAGE ON DATABASE <DATABASE_NAME> TO ROLE INGEST_ADMIN;
GRANT USAGE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE INGEST_ADMIN;
GRANT CREATE STAGE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE INGEST_ADMIN;
GRANT CREATE PIPE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE INGEST_ADMIN;
```

## Configuration

### JSON Configuration File

All Snowflake resources are defined in `input-jsons/snowflake/config.json`:

```json
{
  "warehouses": {
    "load_wh": {
      "name": "LOAD_WH",
      "warehouse_size": "X-SMALL",
      "auto_suspend": 60,
      "auto_resume": true
    }
  },
  "databases": {
    "demo_db": {
      "name": "DEMO_DB",
      "schemas": [
        {
          "name": "SALES",
          "file_formats": { ... },
          "stages": { ... },
          "tables": { ... },
          "snowpipes": { ... }
        }
      ]
    }
  }
}
```

### Terraform Variables

Key variables in `variables.tf`:

| Variable | Description | Default |
|----------|-------------|---------|
| `project_code` | Prefix for resource naming | `snw` |
| `environment` | Environment (devl/test/prod) | `devl` |
| `warehouse_provisioner_role` | Role for warehouse ops | `WAREHOUSE_ADMIN` |
| `db_provisioner_role` | Role for database ops | `PLATFORM_DB_ADMIN` |
| `data_object_provisioner_role` | Role for data objects | `DATA_OBJECT_ADMIN` |
| `ingest_object_provisioner_role` | Role for ingestion | `INGEST_ADMIN` |

## Getting Started

### Prerequisites

| Requirement | Version | Purpose |
|-------------|---------|---------|
| Terraform | >= 1.14.1 | Infrastructure as Code |
| Snowflake Account | Enterprise or higher | Data platform |
| GitHub Account | - | CI/CD and repository hosting |
| AWS Account | - | S3 storage for external stages (optional) |
| OpenSSL | >= 1.1.1 | Key pair generation |

### Step 1: One-Time Snowflake Setup

Before deploying infrastructure, you need to set up the utility infrastructure and admin roles in Snowflake.

#### 1.1 Create Admin Roles

Run the following SQL as `ACCOUNTADMIN`:

```sql
-- ============================================================================
-- Create Admin Roles for Snowflake Governance
-- ============================================================================

-- Create the admin roles
CREATE ROLE IF NOT EXISTS WAREHOUSE_ADMIN
  COMMENT = 'Manages warehouse lifecycle - create, modify, monitor';

CREATE ROLE IF NOT EXISTS PLATFORM_DB_ADMIN
  COMMENT = 'Manages databases and schemas';

CREATE ROLE IF NOT EXISTS DATA_OBJECT_ADMIN
  COMMENT = 'Manages file formats and tables';

CREATE ROLE IF NOT EXISTS INGEST_ADMIN
  COMMENT = 'Manages stages and snowpipes for data ingestion';

-- Grant account-level privileges
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE WAREHOUSE_ADMIN;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE PLATFORM_DB_ADMIN;

-- Set up role hierarchy (roles inherit from SYSADMIN)
GRANT ROLE WAREHOUSE_ADMIN TO ROLE SYSADMIN;
GRANT ROLE PLATFORM_DB_ADMIN TO ROLE SYSADMIN;
GRANT ROLE DATA_OBJECT_ADMIN TO ROLE SYSADMIN;
GRANT ROLE INGEST_ADMIN TO ROLE SYSADMIN;
```

#### 1.2 Grant MANAGE GRANTS Privilege

For Terraform to manage grants between roles, the service account needs `MANAGE GRANTS`:

```sql
-- Grant MANAGE GRANTS to allow cross-role privilege management
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE PLATFORM_DB_ADMIN;
```

### Step 2: Create Service Account with Key-Pair Authentication

#### 2.1 Generate RSA Key Pair

```bash
# Generate private key (encrypted)
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_tf_key.p8 -nocrypt

# Generate public key
openssl rsa -in snowflake_tf_key.p8 -pubout -out snowflake_tf_key.pub

# Extract public key content (remove headers for Snowflake)
grep -v "PUBLIC KEY" snowflake_tf_key.pub | tr -d '\n'
```

#### 2.2 Create Service Account in Snowflake

```sql
-- Create service account user
CREATE USER IF NOT EXISTS TF_SERVICE_ACCOUNT
  TYPE = SERVICE
  COMMENT = 'Service account for Terraform automation'
  DEFAULT_WAREHOUSE = 'COMPUTE_WH'
  DEFAULT_ROLE = 'PLATFORM_DB_ADMIN';

-- Set RSA public key (paste the key content from step 2.1)
ALTER USER TF_SERVICE_ACCOUNT SET RSA_PUBLIC_KEY = '<paste-public-key-here>';

-- Grant all admin roles to service account
GRANT ROLE WAREHOUSE_ADMIN TO USER TF_SERVICE_ACCOUNT;
GRANT ROLE PLATFORM_DB_ADMIN TO USER TF_SERVICE_ACCOUNT;
GRANT ROLE DATA_OBJECT_ADMIN TO USER TF_SERVICE_ACCOUNT;
GRANT ROLE INGEST_ADMIN TO USER TF_SERVICE_ACCOUNT;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE WAREHOUSE_ADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE PLATFORM_DB_ADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DATA_OBJECT_ADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE INGEST_ADMIN;
```

### Step 3: Configure GitHub Secrets and Variables

#### 3.1 Repository Secrets

Navigate to **Settings > Secrets and variables > Actions > Secrets** and add:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `SNOWFLAKE_PRIVATE_KEY` | Contents of `snowflake_tf_key.p8` | RSA private key for authentication |
| `TF_TOKEN_APP_TERRAFORM_IO` | Terraform Cloud API token | For remote state management |

#### 3.2 Repository Variables

Navigate to **Settings > Secrets and variables > Actions > Variables** and add:

| Variable Name | Example Value | Description |
|---------------|---------------|-------------|
| `SNOWFLAKE_ORGANIZATION_NAME` | `MYORG` | Snowflake organization name |
| `SNOWFLAKE_ACCOUNT_NAME` | `AB12345` | Snowflake account identifier |
| `SNOWFLAKE_USER` | `TF_SERVICE_ACCOUNT` | Service account username |

### Step 4: Configure GitHub Codespaces (Optional)

If using GitHub Codespaces for development, add secrets at the user level:

Navigate to **GitHub Settings > Codespaces > Secrets** and add:

| Secret Name | Value |
|-------------|-------|
| `SNOWFLAKE_ORGANIZATION_NAME` | Your organization name |
| `SNOWFLAKE_ACCOUNT_NAME` | Your account identifier |
| `SNOWFLAKE_USER` | `TF_SERVICE_ACCOUNT` |
| `SNOWFLAKE_PRIVATE_KEY` | Contents of private key file |

### Step 5: AWS OIDC Setup (For External Stages)

If using S3 external stages, configure AWS OIDC for secure cross-account access.

#### 5.1 Create IAM OIDC Identity Provider

```bash
# Get Snowflake's OIDC issuer URL
# Format: https://<account>.snowflakecomputing.com

# Create OIDC provider in AWS (via Console or CLI)
aws iam create-open-id-connect-provider \
  --url "https://<org>-<account>.snowflakecomputing.com" \
  --client-id-list "https://<org>-<account>.snowflakecomputing.com" \
  --thumbprint-list "<thumbprint>"
```

#### 5.2 Create IAM Role for Snowflake

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/<org>-<account>.snowflakecomputing.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "<org>-<account>.snowflakecomputing.com:sub": "<snowflake_storage_integration_arn>"
        }
      }
    }
  ]
}
```

#### 5.3 Create Storage Integration in Snowflake

```sql
CREATE STORAGE INTEGRATION IF NOT EXISTS S3_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<AWS_ACCOUNT_ID>:role/snowflake-s3-access'
  STORAGE_ALLOWED_LOCATIONS = ('s3://your-bucket/path/');

-- Get the AWS IAM user ARN and external ID for trust policy
DESC STORAGE INTEGRATION S3_INTEGRATION;
```

### Step 6: Clone and Deploy

#### 6.1 Clone Repository

```bash
git clone https://github.com/subhamay-bhattacharyya/snowflake-de-basic-snowpipe.git
cd snowflake-de-basic-snowpipe
```

#### 6.2 Configure Resources

Edit `input-jsons/snowflake/config.json` with your resource definitions:

```json
{
  "warehouses": {
    "load_wh": {
      "name": "MY_WAREHOUSE",
      "warehouse_size": "X-SMALL",
      "auto_suspend": 60,
      "auto_resume": true
    }
  },
  "databases": {
    "my_db": {
      "name": "MY_DATABASE",
      "schemas": [
        {
          "name": "MY_SCHEMA",
          "file_formats": { ... },
          "tables": { ... }
        }
      ]
    }
  }
}
```

#### 6.3 Local Deployment

```bash
# Set environment variables
export SNOWFLAKE_ORGANIZATION_NAME="your-org"
export SNOWFLAKE_ACCOUNT_NAME="your-account"
export SNOWFLAKE_USER="TF_SERVICE_ACCOUNT"
export SNOWFLAKE_PRIVATE_KEY="$(cat snowflake_tf_key.p8)"

# Deploy
cd infra/snowflake/tf
terraform init
terraform plan
terraform apply
```

#### 6.4 CI/CD Deployment

Push to the `main` branch to trigger the GitHub Actions workflow:

```bash
git add .
git commit -m "feat: initial infrastructure deployment"
git push origin main
```

### Post-Deployment: Grant Schema Privileges

After databases and schemas are created, run these grants to enable cross-role access:

```sql
-- Replace <DATABASE_NAME> and <SCHEMA_NAME> with actual values

-- Grant to DATA_OBJECT_ADMIN (for file formats and tables)
GRANT USAGE ON DATABASE <DATABASE_NAME> TO ROLE DATA_OBJECT_ADMIN;
GRANT USAGE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE DATA_OBJECT_ADMIN;
GRANT CREATE FILE FORMAT ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE DATA_OBJECT_ADMIN;
GRANT CREATE TABLE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE DATA_OBJECT_ADMIN;

-- Grant to INGEST_ADMIN (for stages and pipes)
GRANT USAGE ON DATABASE <DATABASE_NAME> TO ROLE INGEST_ADMIN;
GRANT USAGE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE INGEST_ADMIN;
GRANT CREATE STAGE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE INGEST_ADMIN;
GRANT CREATE PIPE ON SCHEMA <DATABASE_NAME>.<SCHEMA_NAME> TO ROLE INGEST_ADMIN;
```

## Terraform Modules

This project uses external Terraform modules for each resource type:

| Module | Source | Purpose |
|--------|--------|---------|
| `warehouse` | `github.com/subhamay-bhattacharyya-tf/terraform-snowflake-warehouse` | Warehouse management |
| `database_schemas` | `github.com/subhamay-bhattacharyya-tf/terraform-snowflake-database-schema` | Database & schema management |
| `file_formats` | `github.com/subhamay-bhattacharyya-tf/terraform-snowflake-file-format` | File format management |
| `stage` | `github.com/subhamay-bhattacharyya-tf/terraform-snowflake-stage` | Stage management |
| `table` | `github.com/subhamay-bhattacharyya-tf/terraform-snowflake-table` | Table management |
| `pipe` | `github.com/subhamay-bhattacharyya-tf/terraform-snowflake-pipe` | Snowpipe management |

## GitHub Actions

### Workflows

- **ci.yaml**: Runs on pull requests - validates Terraform configuration
- **terraform-deploy.yaml**: Deploys infrastructure on push to main
- **terraform-destroy.yaml**: Manual workflow to destroy infrastructure

### Required Secrets

| Secret | Description |
|--------|-------------|
| `SNOWFLAKE_PRIVATE_KEY` | Snowflake private key for authentication |
| `TF_TOKEN_APP_TERRAFORM_IO` | Terraform Cloud API token |

### Required Variables

| Variable | Description |
|----------|-------------|
| `SNOWFLAKE_ORGANIZATION_NAME` | Snowflake organization |
| `SNOWFLAKE_ACCOUNT_NAME` | Snowflake account |
| `SNOWFLAKE_USER` | Snowflake username |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Commit Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: bug fix
docs: documentation changes
refactor: code refactoring
```

## License

MIT License - See [LICENSE](LICENSE) for details.

## Support

- Open an issue in this repository
- Check [Snowflake documentation](https://docs.snowflake.com/)
