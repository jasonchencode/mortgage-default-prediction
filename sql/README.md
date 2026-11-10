# SQL data checks and exploratory analysis

These queries inspect `public.mortgage_default` without changing the data.
During import, blank CSV values and `Not avail.` were converted to SQL `NULL`;
the original CSV remains unchanged in the Git-ignored `data/raw/` folder.

## Query files

| File | Purpose |
|---|---|
| [data-cleaning/01_missing-values.sql](data-cleaning/01_missing-values.sql) | Count incomplete records and known targets; compare default rates by missingness and number of missing features. |
| [data-cleaning/02_duplicate-records.sql](data-cleaning/02_duplicate-records.sql) | Find exact duplicates across all data columns, excluding the unique source row ID. |
| [data-cleaning/03_invalid-values.sql](data-cleaning/03_invalid-values.sql) | Check basic numeric rules and inspect occupation and marital-status labels. |
| [exploratory-analysis/01_summary-statistics.sql](exploratory-analysis/01_summary-statistics.sql) | Summarize outcome counts, numeric ranges, quartiles, means, standard deviations, and observation dates. |
| [exploratory-analysis/02_default-rate.sql](exploratory-analysis/02_default-rate.sql) | Calculate the overall default rate and compare rates by occupation and marital status. |

Run the data checks before interpreting the exploratory results. Feature-distribution
plots are planned for Python; no distribution queries are currently documented here.

## Running a file

From the repository root, replace `YOUR_PGUSER` with the user configured in `.env`:

```sh
psql -h localhost -U YOUR_PGUSER -d mortgage_default \
  -v ON_ERROR_STOP=1 -f sql/data-cleaning/01_missing-values.sql
```

Enter the database password when prompted. Adjust the host and database name to
match `.env` if needed. `psql` does not automatically load that file.

You can also paste individual queries into pgAdmin's Query Tool.

## Recorded findings

These findings reflect the results recorded in the SQL comments for the current
10,000-row dataset. Rerun the queries after changing the data. Default-rate
interpretations assume `target_var = 1` means default and `0` means non-default;
SQL averages exclude missing targets.

| Finding | Interpretation |
|---|---|
| 9,436 known targets; 564 missing targets | Records without a target cannot directly train or evaluate a supervised classifier. |
| 1,454 defaults and 7,982 non-defaults among known targets | The default rate is 15.41%. Always predicting non-default would achieve 84.59% accuracy, so accuracy alone is insufficient for model evaluation. |
| 4,567 records have at least one missing feature or target | Missing data affects a substantial part of the dataset. |
| 4,003 records with known targets have missing features | Dropping all incomplete records leaves 5,433 records: 54.33% of the original dataset. Investigate missing-value handling before discarding these records. |
| No exact duplicates found | No identical records were found after excluding `source_row_id`. This does not prove each record belongs to a different applicant. |
| No rows violate the numeric rules checked | The checks found no negative incomes or instalment ratios, nonpositive loans, terms or applicant counts, or target codes outside 0 and 1. Other invalid values may still exist. |
| Occupation contains `Worker`, `Employee`, `Student`, and codes `1`, `2`, `3` | Clarify the numeric codes using dataset documentation before recoding them. |
| Several financial variables appear right-skewed, especially instalment-to-income ratio | Inspect plots and extremes before deciding on transformations or outlier treatment. |
| Observation dates span approximately 11 years | Investigate changes over time and consider chronological model evaluation. |

The recorded comparisons suggest default rates differ substantially across some
occupation and marital-status groups (approximately 11-fold for workers versus
employees and 9-fold for separated versus married records). Check group sizes,
uncertainty, and other explanatory features before drawing stronger conclusions.
These are descriptive associations, not evidence of causation.

Missingness comparisons show little apparent relationship with default in the
recorded results. They do not establish statistical insignificance or prove that
values are missing at random.

## Questions to resolve

- What do occupation codes `1`, `2`, and `3` mean?
- What are the documented units and valid ranges for the numeric features?
- How should missing features be handled without introducing information from
  evaluation data into training?
- Do default-rate differences persist after accounting for group sizes, other
  features, and observation period?
- How do feature distributions and default rates change over time?

The current scripts inspect the raw table; they do not delete, impute, or recode
records. Any future cleaned dataset should preserve the raw source table.
