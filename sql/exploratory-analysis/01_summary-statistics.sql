
-- Count applicants by default outcome
SELECT target_var, COUNT(*) AS applicants FROM public.mortgage_default 
WHERE target_var IS NOT NULL
GROUP BY target_var;
-- 0: 7982, 1: 1454


-- Numerical data investigation:
-- calculate available counts, missing counts, 
-- minimum, q1, median, mean, q3, maximum, 
-- standard deviation for each feature
SELECT
    f.feature,
    COUNT(f.value) AS available_count,
    COUNT(*) - COUNT(f.value) AS missing_count,
    ROUND(MIN(f.value), 3) AS minimum,
    ROUND(
        (PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY f.value))::NUMERIC,
        3
    ) AS q1,
    ROUND(
        (PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY f.value))::NUMERIC,
        3
    ) AS median,
    ROUND(AVG(f.value), 3) AS mean,
    ROUND(
        (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY f.value))::NUMERIC,
        3
    ) AS q3,
    ROUND(MAX(f.value), 3) AS maximum,
    ROUND(STDDEV_SAMP(f.value), 3) AS standard_deviation
FROM public.mortgage_default AS m
CROSS JOIN LATERAL (
    VALUES
        ('income', m.income),
        ('loan_amount', m.loan_amount),
        ('term_length', m.term_length::NUMERIC),
        ('install_to_inc', m.install_to_inc),
        ('schufa', m.schufa),
        ('num_applic', m.num_applic::NUMERIC)
) AS f(feature, value)
GROUP BY f.feature
ORDER BY f.feature;
-- revealed right-skewed distributions in several financial variables, 
-- particularly instalment-to-income ratio


-- Overview of significant statistics:
-- total records, records with known target, 
-- earliest observation, latest observation, 
-- missing dates
SELECT
    COUNT(*) AS total_records,
    COUNT(target_var) AS records_with_known_target,
    MIN(obs_date) AS earliest_observation,
    MAX(obs_date) AS latest_observation,
    COUNT(*) FILTER (WHERE obs_date IS NULL) AS missing_dates
FROM public.mortgage_default;
-- 11 year span