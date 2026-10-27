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
