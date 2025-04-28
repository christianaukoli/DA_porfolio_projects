-- Data Cleaning Project --
# create database, insert dataset, clean data

SELECT *
FROM world_layoffs.layoffs;
# if you double click the schema, you don't have to use the dot notation every time. but I've done it this first time as a(n) example/reminder

# steps to clean this data
-- 1. Remove Duplicates if there are any
-- 2. Standardize the Data - spelling, upper/lower, etc
-- 3. Null/blank Values - see if we should fill them in or not
-- 4. Remove Unnecessary Columns/Rows 
# If working with large data and there's an unused column with no ETL process (extract, transform, load) 
# we can remove it. But in the real world, if you remove a column from the raw dataset that might be populated from different places,
# that's a big problem. So we'll do it another way. Must create staging table first and do work from there so if we make a mistake it doesn't
# impact the raw data. 
    
# Create a staging table
CREATE TABLE layoffs_staging
LIKE layoffs;

# copy raw data into staging
INSERT layoffs_staging
SELECT *
FROM layoffs;

# run staging to see if it transferred
SELECT *
FROM layoffs_staging;


-- 1. IDENTIFYING AND REMOVING DUPLICATES --
# below is helping to identify which items are unique 
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;
# row num should be 1 meaning there's only 1 of it. if it's 2 or greater that means there's duplicates

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
# this is pulling a list of all the entries that are greater than 1, i.e., duplicates

# this was where we tested duplicates we initially caught to see what the actual line items look like
SELECT *
FROM layoffs_staging
WHERE company = "Casper";
# upon runnning initially, items weren't the same so we needed to put more columns in our partition.
# PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date` wasn't enough. we need to change it to all the columns.

# now that we have our list of duplicates, we need to identify the exact rows to delete ONE duplicate. Not both entries.
# other SQL tools you can delete rows directly in a CTE but not MySQL. Error says CTE is not updatable and "delete" is technically an update
# what we'll do is create a table with an extra column for row_num and delete those rows where it's equal to 2

# create new table using right click layoffs_staging, copy to clipboard, create statement. changed name to staging2
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
# added row_num column to help us sort to prep to delete

# checking to see if the table was created
SELECT *
FROM layoffs_staging2
;

# inserting CTE data into new table so we can delete ...since we can't delete rows in a CTE
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

# finding duplicates in our new table using row num
SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

# deleting the duplicates in our new table
DELETE
FROM layoffs_staging2
WHERE row_num > 1
;
# DONE

-- 2. STANDARDIZING DATA --
# looking at the data side by side and removing white space
SELECT company, TRIM(company)
FROM layoffs_staging2;

# updating the data to use the trimmed data
UPDATE layoffs_staging2
SET company = TRIM(company);

# looking at the industries and putting them in alphabetical order to easily see any that are the same
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
# order by 1 because it's the first column, can also order by column name
;

# since we found different versions of crypto, we need to look at them all and update them
SELECT *
FROM layoffs_staging2
WHERE industry LIKE "Crypto%"
# remember % is how to say "anything behind Crypto"
# 'crypto' was in all 3 names when we ordered the column, so searching for LIKE crypto will list them all out
;

# make all crypto titles the same - since majority are simply Crypto, that will be the name for all
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE "Crypto%";
# after check that it has changed - check when we ordered by industry using distinct

# look at location
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

# look at country
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;
# United States has 2 different types of entries. Have to set them to be the same

# viewing country entries side by side
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
# trailing period will be removed from US entries
FROM layoffs_staging2
ORDER BY 1
;

# making all US entries the same since there were multiple
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

# looking at the date - right now it's text and needs to be in date format
# if we need to do time series or exploratory data analysis, we need it in date format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
# string to date - need the column we're converting and the format we want, lower m for month, lower d for day, capital Y for 4 digit year
FROM layoffs_staging2
;

# updating the date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

# converting date column from text to date datatype - wouldn't have worked before but we can do it now
# NEVER do this on raw data. This is why we copy data first to a table we can work on.
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE
;

-- 3. NULL and Blank values --
# what do we want to do? do we make them all null, all blank, populate them?

# looking at industry for nulls and blanks
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
;
# maybe we can fill in the blanks if other entries tell us which industry the company is insert

# checking other entries to see if we can find the correct industry to fill in our blanks
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'
;
# joining table with itself to look at blank industry columns side by side with non blank industry columns
SELECT *
FROM layoffs_staging2 table1
JOIN layoffs_staging2 table2
	ON table1.company = table2.company
    AND table1.location = table2.location
    # make sure the location is the same just in case different locations have different industries
WHERE (table1.industry = '' OR table1.industry IS NULL)
AND (table2.industry IS NOT NULL OR table2.industry != "")
;

# lets set blanks to nulls first
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ""
;

# updating blank industry Airbnb row
UPDATE layoffs_staging2 table1
JOIN layoffs_staging2 table2
	ON table1.company = table2.company
SET table1.industry = table2.industry
WHERE table1.industry IS NULL
AND table2.industry IS NOT NULL
;
# this worked since we set blanks to null first

# Bally's is the only null industry left. let's work on that
SELECT *
FROM layoffs_staging2
WHERE company LIKE "Bally%"
;
# Bally's only has 1 layoff entry so there was no populated row to help fill it in

# That's all the null values we'll change. we don't have enough information to make calculations.

# looking at total laid off and percent laid off for nulls
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;
# these might be useless to us since both columns are null
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;
# removing these rows since we can't use them for our exploratory analysis in the next step

# removing row_num column that we added
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

# looking at our final data
SELECT *
FROM layoffs_staging2
;
