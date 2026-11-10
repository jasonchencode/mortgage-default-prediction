-- Calculates the default rate as a percentage for data points with known outcomes
SELECT
    COUNT(target_var) AS known_outcomes,
    COUNT(*) FILTER (WHERE target_var = 1) AS defaults,
    COUNT(*) FILTER (WHERE target_var = 0) AS non_defaults,
    ROUND(100.0 * AVG(target_var), 2) AS default_rate_pct
FROM public.mortgage_default;
-- 15.41%


-- For occup and marital features, list each category's default rate percentage
SELECT
    f.feature,
    COALESCE(f.category, '[Missing]') AS category,
    COUNT(*) AS total_records,
    COUNT(m.target_var) AS known_outcomes,
    COUNT(*) FILTER (WHERE m.target_var = 1) AS defaults,
    ROUND(100.0 * AVG(m.target_var), 2) AS default_rate_pct
FROM public.mortgage_default AS m
CROSS JOIN LATERAL (
    VALUES
        ('occup', m.occup),
        ('marital', m.marital)
) AS f(feature, category)
GROUP BY f.feature, f.category
ORDER BY f.feature, default_rate_pct DESC NULLS LAST;
-- 9x difference between separated and married applicants
-- 11x difference between workers and employees