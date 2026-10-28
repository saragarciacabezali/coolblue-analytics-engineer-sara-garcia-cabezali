# Analytics Engineer Assignment

This project contains the data model and data architecture for Delta's campaign analytics: a dashboard showing quantity sold, actual vs forecast performance and top campaigns.

The documentation is split in two parts:

- **[Data model](data_model.md)** (Question 1): the dimensional model, design choices (grain, facts, dimensions, SCD strategy, bridge tables) and the schema diagram.
- **[Extraction pipeline](extraction_pipeline.md)** (Question 2): how both source systems are ingested into the warehouse and how dbt transforms them into the model.

The dbt project in this repository implements the model on BigQuery. The source tables are loaded as dbt seeds with generated sample data, replacing the GCS external tables described in the extraction pipeline.

## Requirements

Before getting started, make sure you have:

- Python 3.9+ (recommended 3.10 or newer)
- Git
- A terminal with shell access
- Access to a BigQuery project and dataset
- A Google Cloud service account JSON key file for BigQuery authentication

The project is currently configured to use a service account key at keys/bigquery.json via the profile in profiles.yml. In this repo, that means having the JSON key file at keys/bigquery.json and permission to use the target project and dataset.

## Initial Setup

From the project root, run:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install dbt-core dbt-bigquery
dbt deps
```

These commands create an isolated Python environment and install dbt with the BigQuery adapter as well as dbt packages needed for the project.

If you want a quick shell alias for this project, run:

```bash
make install-alias
```

You can then use:

```bash
coolblue-analytics-engineer
```

## Conventions

### Layers and model names

| Layer | Folder | Prefix | Materialization | Tag |
| --- | --- | --- | --- | --- |
| Sources | `models/sources` | `src_` | table | `src` |
| Snapshots | `snapshots` | `snapshot_src_` | snapshot | `src` |
| Intermediate | `models/intermediate` | `int_` | table | `int` |
| Dimensions | `models/dimensions` | `dim_` | table | `dim` |
| Facts | `models/facts` | `fact_` | table | `fact` |
| Marts | `models/marts` | none | view | `mart` |

### Column names

- `_id` is a natural key from the source; `_key` is a surrogate key, one per version of a Type 2 dimension.
- `valid_from` / `valid_to` define the validity period of a version; `valid_to` is exclusive and NULL for the current version.

### Types

- **Identifiers** are STRING. The exception is `date_id`, an INT64 in `YYYYMMDD` form.
- **Exact business values** are NUMERIC and calculated ratios are FLOAT64.
- **Dates** are DATE, as local business dates.
- **Casting happens only in the `src_` layer,** with `CAST` (not `SAFE_CAST`), so invalid values fail loudly instead of becoming NULL. Downstream models don't recast.

### SQL style

- Every step is its own named CTE; no subqueries in `FROM`.
- Each model ends with a `final` CTE and `SELECT * FROM final`.
- SQL keywords in uppercase, explicit table aliases, and single quotes for string literals.
- Placeholder rows use `'-1'` as their key.

### Tests

- Source models test the incoming data: keys, relationships, and value ranges.
- Downstream models only test what their own logic could break (joins, unions, Type 2 versions), to avoid redundancy.
