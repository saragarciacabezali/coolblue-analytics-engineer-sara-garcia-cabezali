# Analytics Engineer Assignment

This project contains the data model and data architecture for Delta's campaign analytics: a dashboard showing quantity sold, actual vs forecast performance and top campaigns.

The documentation is split in two parts:

- **[Data model](data_model.md)** (Question 1): the dimensional model, its design choices (grain, facts, dimensions, SCD strategy, bridge tables) and the schema diagram.
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

| Layer | Folder | Prefix | Materialization | Tag | Purpose |
| --- | --- | --- | --- | --- | --- |
| Sources | `models/sources` | `src_` | table | `src` | Cast and rename the raw tables; no business logic |
| Snapshots | `snapshots` | `snapshot_src_` | snapshot | `src` | History of the source tables that only hold current state |
| Intermediate | `models/intermediate` | `int_` | table | `int` | Reusable logic between sources and the final model (e.g. campaign membership) |
| Dimensions | `models/dimensions` | `dim_` | table | `dim` | Descriptive context: date, store, product, product type, campaign |
| Facts | `models/facts` | `fact_` | table | `fact` | Measurable events at a declared grain |
| Marts | `models/marts` | none | view | `mart` | Reporting models for the dashboard; views so date-dependent logic is always current |

### Column names

| Pattern | Meaning | Example |
| --- | --- | --- |
| `<entity>_id` | Natural key from the source (STRING) | `store_id`, `campaign_id` |
| `<entity>_key` | Surrogate key, one per version of a Type 2 dimension (STRING) | `store_key`, `product_key` |
| `<entity>_name` | Readable label | `campaign_name`, `month_name` |
| `<event>_date` | Calendar date (DATE) | `order_date`, `start_date` |
| `valid_from` / `valid_to` | Validity period of a version; `valid_to` is exclusive and NULL for the current version | `dim_store`, `dim_product` |
| `is_<condition>` | Boolean flag | `is_current`, `is_running` |
| `iso_` prefix | ISO calendar (weeks Monday to Sunday) | `iso_year_id`, `iso_week_of_year` |

### Types and units

- **Identifiers** are STRING. The exception is `date_id`, an INT64 in `YYYYMMDD` form, so it sorts and filters chronologically.
- **Whole numbers** are INT64: quantities are counted in units sold (`quantity`, `forecast_quantity`), and percentages are whole numbers (`discount_perc = 25` means 25%).
- **Ratios** are decimals: `actual_vs_forecast_ratio = 1.12` means 12% above forecast.
- **Dates** are DATE, as local business dates. Snapshot timestamps are converted to DATE for validity periods.
- **Casting happens only in the `src_` layer,** with `CAST` (not `SAFE_CAST`), so invalid values fail loudly instead of becoming NULL. Downstream models don't re-cast.

### SQL style

- Every step is its own named CTE; no subqueries in `FROM`.
- Each model ends with a `final` CTE and `SELECT * FROM final`.
- SQL keywords in uppercase, explicit table aliases, and single quotes for string literals.
- Comments explain why, not what.
- Placeholder rows use `'-1'` as their key (e.g. the "No campaign" row in `dim_campaign`).

### Tests

- Source models test the incoming data: keys, relationships, and value ranges.
- Downstream models only test what their own logic could break (joins, unions, Type 2 versions), instead of repeating source tests.
