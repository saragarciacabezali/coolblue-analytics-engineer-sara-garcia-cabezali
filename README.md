# dbt Learning Project

This repository is a simple starting point for learning dbt and practicing data transformations in a way that mirrors how real analytics engineering work is structured.

## What this repo is for

The goal is not just to learn syntax. The goal is to become someone who can:
- set up a dbt project from scratch
- understand the purpose of each part of a dbt repo
- jump into an unfamiliar company project and orient yourself quickly
- build reliable models with tests, documentation, and maintainable structure

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
