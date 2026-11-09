
-- Check how many rows exactly have missing features: 0 < missing features
SELECT COUNT(*) AS rows_with_missing_features FROM public.mortgage_default
WHERE 
    income IS NULL OR
    loan_amount IS NULL OR
    term_length IS NULL OR
    install_to_inc IS NULL OR
    occup IS NULL OR
    marital IS NULL OR
    schufa IS NULL OR
    num_applic IS NULL OR
    obs_date IS NULL OR
    target_var IS NULL;
-- 4,567

-- Check how many rows with target values (important) have missing features: 0 < missing features AND target_var is an actual value
SELECT COUNT(*) AS predicted_rows_with_missing_features FROM public.mortgage_default
WHERE 
    (income IS NULL OR
    loan_amount IS NULL OR
    term_length IS NULL OR
    install_to_inc IS NULL OR
    occup IS NULL OR
    marital IS NULL OR
    schufa IS NULL OR
    num_applic IS NULL OR
    obs_date IS NULL)
    AND
    target_var IS NOT NULL;
-- 4,003 


-- Count how many rows have a target_var (necessary for training)
SELECT COUNT(*) AS rows_with_target FROM public.mortgage_default
WHERE target_var IS NOT NULL;
-- 9,436
-- If we were to remove all rows that have a missing feature,
-- we would have 9436-4003 = 5433 rows 
-- Losing almost half of our original data


-- Check if there is an association between missing values and mortgage default rates
SELECT
    f.feature_name,

    COUNT(*) FILTER (
        WHERE f.is_missing
    ) AS missing_count,

    ROUND(
        AVG(m.target_var) FILTER (
            WHERE f.is_missing
        ) * 100, 2
    ) AS missing_default_rate,

    ROUND(
        AVG(m.target_var) FILTER (
            WHERE NOT f.is_missing
        ) * 100, 2
    ) AS available_default_rate

FROM public.mortgage_default AS m

CROSS JOIN LATERAL (
    VALUES
        ('income', m.income IS NULL),
        ('loan_amount', m.loan_amount IS NULL),
        ('term_length', m.term_length IS NULL),
        ('install_to_inc', m.install_to_inc IS NULL),
        ('occup', m.occup IS NULL),
        ('marital', m.marital IS NULL),
        ('schufa', m.schufa IS NULL),
        ('num_applic', m.num_applic IS NULL),
        ('OBS_DATE', m.obs_date IS NULL)
) AS f(feature_name, is_missing)

WHERE m.target_var IS NOT NULL

GROUP BY f.feature_name

ORDER BY f.feature_name;
-- No clear correlation, around 1.5pp in difference


-- Check if number of missing features per applicant is significant
WITH missing_counts AS (
    SELECT
        target_var,

        (
            (income IS NULL)::INT +
            (loan_amount IS NULL)::INT +
            (term_length IS NULL)::INT +
            (install_to_inc IS NULL)::INT +
            (occup IS NULL)::INT +
            (marital IS NULL)::INT +
            (schufa IS NULL)::INT +
            (num_applic IS NULL)::INT +
            (obs_date IS NULL)::INT
        ) AS missing_feature_count

    FROM public.mortgage_default

    WHERE target_var IS NOT NULL
)

SELECT
    missing_feature_count,
    COUNT(*) AS applicants,
    ROUND(AVG(target_var) * 100, 2) AS default_rate

FROM missing_counts

GROUP BY missing_feature_count

ORDER BY missing_feature_count;
-- # of missing features has little apparent relationship with default risk
