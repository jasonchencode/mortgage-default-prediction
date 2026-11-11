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


## Our data preparation strategy

The initial decisions below combine our SQL findings with business reasoning.
They are provisional: inclusion does not yet establish predictive usefulness.
They describe the planned modelling pipeline, not changes to the raw database.
Confirm that each predictor was available when the application was assessed,
and clarify units, score definitions, and category codes before interpreting it.

| Feature | Preprocessing decision | Reason |
|---|---|---|
| Income | Include provisionally; median imputation and scaling | Represents repayment capacity; verify income definition and inspect skew. |
| Loan Amount | Include provisionally; median imputation and scaling | Represents requested credit exposure; investigate its relationship with income. |
| Term Length | Include provisionally; median imputation and scaling | Describes repayment duration; confirm units and investigate extremes and nonlinear patterns. |
| Instalment/Income | Include provisionally; median imputation and scaling | Describes repayment burden; verify the ratio definition and inspect substantial right skew before testing a log transformation. |
| SCHUFA | Include provisionally; median imputation and scaling | Potential creditworthiness signal; confirm the dataset's score scale and direction. |
| Number of Applicants | Mode imputation | Discrete feature with observed non-missing values of 1 or 2. |
| Occupation | Preserve categories, use `Unknown` for missing, then one-hot encode | Avoid unsupported classifications, including assumptions about codes `1`, `2`, and `3`. |
| Marital Status | Exclude from primary model | Project choice motivated by fairness and legal considerations; exclusion alone does not establish fairness or legal compliance. |
| Observation Date | Retain for validation, not as an initial predictor | Evaluate performance over time without assuming the date is a useful predictor. |
| Default Flag (`target_var`) | Exclude missing outcomes from supervised training and evaluation | Supervised learning requires a known target; retain these records separately for possible later predictions. |

### Development sequence

1. Preserve the original CSV and raw PostgreSQL table. Keep credentials, data,
   and generated model artifacts out of Git.
2. Separate the 564 records without targets from the 9,436 labelled records.
   Do not impute outcomes. Retain unlabelled records for possible later predictions.
3. Use the frozen chronological split: 2008–2015 for training, 2016 for
   validation, and 2017–2018 for final testing. Keep labelled records without
   observation dates outside this evaluation initially. Further exploration uses
   only the development portion (training plus validation); the test set remains
   untouched until all preprocessing and modelling choices are fixed. Existing
   whole-dataset SQL exploration is preliminary.
4. Use Python on development data to inspect numeric histograms and box plots by
   default outcome. Compare default rates across quantile groups, showing group
   counts and confidence intervals. For applicant count, compare discrete groups.
   Report missing values separately. These plots show descriptive associations,
   not proof of predictive usefulness or causation.
5. Fit preprocessing and a simple logistic-regression baseline in one pipeline.
   Start without automatic outlier removal or log transformations. Compare
   transformations, missing-value indicators, and any derived features using
   training/validation data only. Do not discard plausible extremes solely
   because they are unusual.
6. Assess numeric variables individually and together. Compare validation
   performance when omitting each feature to assess additional contribution;
   correlated features may provide overlapping information. Check stability
   across observation periods before finalizing the feature set.
7. Evaluate discrimination, probability calibration, and decision thresholds.
   Report PR-AUC, ROC-AUC, precision, recall, and confusion matrices rather than
   relying on accuracy alone. Choose thresholds on validation data and explain
   the trade-off between missed defaults and rejected non-defaults. Use the
   reserved test set for final evaluation, not model selection.

### Preprocessing safeguards

Split the data before fitting preprocessing. Learn medians, modes, category
encodings, and scaling parameters from training data only, including within each
cross-validation fold. Apply the fitted pipeline to validation and test data;
configure the encoder to handle unseen categories.

Scaling supports models such as logistic regression but is generally unnecessary
for tree models. Scaling does not remove skew or resolve invalid extreme values.
Exclude `source_row_id` from predictors and preserve the raw PostgreSQL table.
For chronological validation, handle records without observation dates separately.

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
