-- Query to extract average retention months per cohort and subscription plan

WITH cohort_aux as(
SELECT
    account_id,
    CONVERT(VARCHAR(7), MIN(start_date), 120) AS cohort_month
FROM sales
GROUP BY account_id
)

, AUX_2 AS( 

select s.*, cohort_month
from sales as s 
left join cohort_aux as aux 
on (s.account_id=aux.account_id)
)

select cohort_month AS Cohort, 
    sub_plan AS Type_of_Plan, 
    COUNT(distinct account_id) as Users_per_Cohort, 
    COUNT(account_id) as Users_Retained, 
    (COUNT(account_id) / COUNT(distinct account_id)) as Avg_Retention_Months

from AUX_2
GROUP BY cohort_month, sub_plan
ORDER by cohort_month, sub_plan

-- Query to extract users and user purchases per cohort and subscription plan (Retention per Cohort and Retention Rate per Subscription sheets)

WITH cohort_aux as(
SELECT
    account_id,
    CONVERT(VARCHAR(7), MIN(start_date), 120) AS cohort_month
FROM sales
GROUP BY account_id)

, retention_aux AS(
select s.order_id, 
    s.account_id, 
    CONVERT(VARCHAR(7), s.start_date, 120) AS purchase_month, 
    s.sub_plan, 
    cohort_month,
    CASE
        WHEN CONVERT(VARCHAR(7), s.start_date, 120) <> cohort_month THEN s.account_id
        ELSE NULL
    END AS retention_id
from sales as s 
left join cohort_aux as aux 
on (s.account_id=aux.account_id)
)

select cohort_month, 
    sub_plan,
    purchase_month,
    account_id
    
from retention_aux
order by cohort_month, sub_plan


-- Query to extract 1 month retention per cohort and subscription plan

WITH cohort_aux as(
SELECT
    account_id,
    CONVERT(VARCHAR(7), MIN(start_date), 120) AS cohort_month
FROM sales
GROUP BY account_id)

, retention_aux AS(
select s.order_id, 
    s.account_id, 
    CONVERT(VARCHAR(7), s.start_date, 120) AS purchase_month, 
    s.sub_plan, 
    cohort_month,
    CASE
        WHEN CONVERT(VARCHAR(7), s.start_date, 120) <> cohort_month THEN s.account_id
        ELSE NULL
    END AS retention_id
from sales as s 
left join cohort_aux as aux 
on (s.account_id=aux.account_id)
)

select cohort_month AS Cohort, 
    sub_plan AS Type_of_Plan, 
    COUNT(DISTINCT retention_aux.account_id) AS Users_per_Cohort, 
    COUNT(DISTINCT retention_aux.retention_id) AS Users_Retained,
    CAST(COUNT(DISTINCT retention_aux.retention_id) AS DECIMAL) / CAST(COUNT(DISTINCT retention_aux.account_id) AS DECIMAL) * 100.0 AS Retention_Rate

from retention_aux
group by cohort_month, sub_plan
order by cohort_month, sub_plan


-- Query to extract 1 month Retention Rate per Subscription Plan

WITH cohort_aux as(
SELECT
    account_id,
    CONVERT(VARCHAR(7), MIN(start_date), 120) AS cohort_month
FROM sales
GROUP BY account_id)

, retention_aux AS(
select s.order_id, 
    s.account_id, 
    CONVERT(VARCHAR(7), s.start_date, 120) AS purchase_month, 
    s.sub_plan, 
    cohort_month,
    CASE
        WHEN CONVERT(VARCHAR(7), s.start_date, 120) <> cohort_month THEN s.account_id
        ELSE NULL
    END AS retention_id
from sales as s 
left join cohort_aux as aux 
on (s.account_id=aux.account_id)
)

select  
    sub_plan AS Type_of_Plan, 
    COUNT(DISTINCT retention_aux.account_id) AS Users_per_Cohort, 
    COUNT(DISTINCT retention_aux.retention_id) AS Users_Retained,
    CAST(COUNT(DISTINCT retention_aux.retention_id) AS DECIMAL) / CAST(COUNT(DISTINCT retention_aux.account_id) AS DECIMAL) * 100.0 AS Retention_Rate

from retention_aux
group by sub_plan
order by sub_plan
