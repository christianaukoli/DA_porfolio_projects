-- Prompt --
-- How have American baby name tastes changed since 1920? Which names have remained popular for over 100 years, and how do those names compare to more recent top baby names? These are considerations for many new parents, but the skills you'll practice while answering these queries are broadly applicable. After all, understanding trends and popularity is important for many businesses, too!

-- You'll be working with data provided by the United States Social Security Administration, which lists first names along with the number and sex of babies they were given to in each year. For processing speed purposes, the dataset is limited to first names which were given to over 5,000 American babies in a given year. The data spans 101 years, from 1920 through 2020.

-----------------------------------------------------------------------------------------------------------------------------

-- List the overall top five names in alphabetical order and find out if each name is "Classic" or "Trendy."

SELECT 
	first_name, 
	SUM(num) AS sum, 
	CASE WHEN COUNT(year) >= 50 THEN 'Classic'
		ELSE 'Trendy' END AS popularity_type
FROM public.baby_names
GROUP BY first_name
ORDER BY first_name
LIMIT 5;

-----------------------------------------------------------------------------------------------------------------------------

-- What were the top 20 male names overall, and how did the name Paul rank?

SELECT
	RANK() OVER(ORDER BY SUM(num) DESC) AS name_rank,
	first_name,
	SUM(num) AS sum
FROM public.baby_names
WHERE sex = 'M'
GROUP BY first_name
LIMIT 20;

-----------------------------------------------------------------------------------------------------------------------------

-- Which female names appeared in both 1920 and 2020?

SELECT
	first_name,
	COUNT(year) AS total_occurrences
FROM baby_names
WHERE SEX = 'F'
	AND first_name IN 
	(SELECT first_name
	FROM public.baby_names
	WHERE year IN (1920, 2020))
GROUP BY first_name;
