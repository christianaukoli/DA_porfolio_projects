-- Prompt --
-- Humans not only take debts to manage necessities. A country may also take debt to manage its economy. For example, infrastructure spending is one costly ingredient required for a country's citizens to lead comfortable lives. The World Bank is the organization that provides debt to countries.

-- In this project, you are going to analyze international debt data collected by The World Bank. The dataset contains information about the amount of debt (in USD) owed by developing countries across several categories. You are going to find the answers to the following questions:

--     What is the number of distinct countries present in the database?
--     What country has the highest amount of debt?
--     What country has the lowest amount of repayments?

-------------------------------------------------------------------------------------------------------------------------------

-- num_distinct_countries 
SELECT COUNT(DISTINCT country_name) AS total_distinct_countries
FROM public.international_debt;

-------------------------------------------------------------------------------------------------------------------------------

-- highest_debt_country 
SELECT country_name, SUM(debt) AS total_debt
FROM public.international_debt
GROUP BY country_name
ORDER BY SUM(debt) DESC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------

-- lowest_principal_repayment 
SELECT country_name, indicator_name, debt AS lowest_repayment
FROM public.international_debt
WHERE indicator_code = 'DT.AMT.DLXF.CD'
ORDER BY debt
LIMIT 1;
