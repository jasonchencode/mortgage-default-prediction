
-- Check if there are any duplicated rows (can't say for sure if they are the same applicant)
SELECT
    income,
    loan_amount,
    term_length,
    install_to_inc,
    occup,
    marital,
    schufa,
    num_applic,
    obs_date,
    target_var,
    COUNT(*) AS occurrences,
    ARRAY_AGG(source_row_id ORDER BY source_row_id) AS source_row_ids
FROM public.mortgage_default
GROUP BY
    income, loan_amount, term_length, install_to_inc,
    occup, marital, schufa, num_applic, obs_date, target_var
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;
-- 0 duplicated rows