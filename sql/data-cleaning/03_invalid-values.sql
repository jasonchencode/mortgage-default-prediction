
-- Check numeric values that may violate expectations
SELECT
    source_row_id,
    income,
    loan_amount,
    term_length,
    install_to_inc,
    num_applic,
    target_var
FROM public.mortgage_default
WHERE income < 0
   OR loan_amount <= 0
   OR term_length <= 0
   OR install_to_inc < 0
   OR num_applic <= 0
   OR target_var NOT IN (0, 1);
-- 0 rows

-- Identify all category labels for occupation and marital
SELECT 'occup' AS column_name, occup AS category, COUNT(*) AS records
FROM public.mortgage_default
GROUP BY occup

UNION ALL

SELECT 'marital', marital, COUNT(*)
FROM public.mortgage_default
GROUP BY marital

ORDER BY column_name, records DESC;
-- 6 different marital labels
    -- Single, Separated, Divorced, Married, Living together, (empty)
-- 7 different occupation labels
    -- Worker, Employee, Student, 1, 2, 3, (empty)
