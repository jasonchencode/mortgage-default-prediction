
-- Count applicants by default outcome
SELECT target_var, COUNT(*) AS applicants FROM public.mortgage_default 
WHERE target_var IS NOT NULL
GROUP BY target_var;
-- 0: 7982, 1: 1454

