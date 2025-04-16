-- Exploratory Data Analysis (EDA) Project --
# EDA Process
# Exploring and looking at everything

SELECT *
FROM layoffs_staging2
;

# looking at the max lay offs
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2
;
# returning 1 means 100% of the company is laid off

# looking at the companies who dissolved and had 100% layoffs
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
;

# looking at the total layoffs by company - remember Group By rolls sum into 1 row while Partition does multiple rows
SELECT company, SUM(total_laid_off) sum_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY sum_laid_off DESC
;

# looking at the date range of this data
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2
;

# looking at the country layoffs
SELECT country, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
;

# looking at layoffs by the year
SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC
;

# looking at layoffs at different stages
SELECT stage, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC
;

# looking at layoff percentages
SELECT company, AVG(percentage_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 1 DESC
;
# looking in different ways, sum/avg, 1/2 desc.. we see that percent laid off isn't very helpful to us

# starting at the earliest layoffs, do a rolling total of layoffs until the end of the layoffs by month
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
# 1 is the position, 7 is the number of characters to pull
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;
# this broke the data down into sum per each month of each year

# using CTE because a CTE is how you put a function into a function (query into a query)
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS monthly_total_laid_off
# 1 is the position, 7 is the number of characters to pull
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, monthly_total_laid_off, SUM(monthly_total_laid_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total
;
# this created a rolling total of each month that we broke the data down into in the previous step

# looking at how much each company was laying off per year
# lets rank which years they laid off the most people
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;

WITH Company_Year (company, years, total_laid_off) AS
# remember you can override the column headers by passing them in as parameters
(
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
# this is ranking them by the leader of layoffs each year - highest of each year to lowest of each year 
# you'll have topped ranked for each year down to least ranked for each year 
FROM Company_Year
WHERE years IS NOT NULL 
;

# looking to filter for the top 5 ranked for each year with another CTE
WITH Company_Year (company, years, total_laid_off) AS
# remember you can override the column headers by passing them in as parameters
(
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL 
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5
;
