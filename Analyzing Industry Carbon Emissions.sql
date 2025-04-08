-- Prompt --

-- When factoring heat generation required for the manufacturing and transportation of products, Greenhouse gas emissions attributable to products, from food to sneakers to appliances, make up more than 75% of global emissions. (Source: The Carbon Catalogue https://www.nature.com/articles/s41597-022-01178-9)

-- Our data, which is publicly available on nature.com, contains product carbon footprints (PCFs) for various companies. PCFs are the greenhouse gas emissions attributable to a given product, measured in CO2 (carbon dioxide equivalent).

-------------------------------------------------------------------------------------------------------------------------------

-- Using the product_emissions table, find the number of unique companies and their total carbon footprint PCF for each industry group, filtering for the most recent year in the database. The query should return three columns: industry_group, num_companies, and total_industry_footprint, with the last column being rounded to one decimal place. The results should be sorted by total_industry_footprint from highest to lowest values.

SELECT industry_group, 
	COUNT(DISTINCT company) AS num_companies, 
	ROUND(SUM(carbon_footprint_pcf),1) AS total_industry_footprint
FROM product_emissions
WHERE year = (
	SELECT MAX(year)
	FROM product_emissions)
GROUP BY industry_group
ORDER BY total_industry_footprint DESC;
