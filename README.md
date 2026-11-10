# Mortgage Credit Risk Prediction and Automated Loan Decisioning

## Client Characteristics
| Feature | Definition | Relevance to Mortgage Default |
|---|---|---|
| **Income** | Applicant's reported earnings (period and gross/net basis unspecified). | Indicates repayment capacity. |
| **Loan Amount** | Total mortgage amount requested. | Affects repayment obligations. |
| **Term Length** | Scheduled repayment duration (unit unspecified). | Affects payments and credit exposure. |
| **Instalment/Income** | Scheduled loan payment relative to income. | Measures repayment burden and potential financial stress. |
| **Occupation** | Applicant's employment classification. | May reflect income stability. |
| **Marital Status** | Applicant's relationship status. | May correlate with household finances; raises fairness concerns. |
| **SCHUFA** | Creditworthiness indicator associated with Germany's credit reporting system (dataset scale unverified). | May help predict repayment risk. |
| **Number of Applicants** | Number of people jointly applying for a mortgage. | May reflect shared income and repayment responsibility. |
| **Observation Date** | Date associated with the applicant record. | Useful for temporal analysis and validation. |
| **Default Flag (`target_var`)** | Whether the borrower subsequently defaulted (1 = Yes, 0 = No). | **Prediction target**, not an input feature. |


## Python environment

Create the local virtual environment (Python 3.14):

```sh
python3 -m venv .venv
```

Activate it on macOS/Linux:

```sh
source .venv/bin/activate
```

In your IDE, select `.venv/bin/python` as the Python interpreter.
Run `deactivate` to leave the environment.

## PostgreSQL credentials

Store your local connection settings in `.env`. Fill in `PGUSER` and
`PGPASSWORD`, and adjust `PGHOST`, `PGPORT`, and `PGDATABASE` to match your
database. The database name defaults to `mortgage_default`.

`.env` is excluded from Git. Keep real credentials there; `.env.example` is
the template for sharing the required settings. On a fresh checkout, run:

```sh
cp .env.example .env
```

The importer loads these settings automatically. The PostgreSQL database
must already exist.

## Import the mortgage data

The original CSV belongs at `data/raw/mortgage_default_data.csv`. Both `data/`
and CSV files are excluded from Git.

```sh
source .venv/bin/activate
pip install -r requirements.txt
python postgres-connect.py
```

This creates `public.mortgage_default` and imports the CSV in one transaction.
It validates the data first, maps blanks and `Not avail.` to SQL `NULL`, parses
observation timestamps, and preserves the unnamed CSV index as `source_row_id`.
It refuses to overwrite an existing table. All source rows are preserved;
missing values are not imputed.
