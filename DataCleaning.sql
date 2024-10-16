-- Data Cleaning Project Using SQL


USE company_layoffs_2024;

SELECT * FROM layoffs_data;

-- create a staging table to work and clean the data

CREATE TABLE layoffs_data_staging
LIKE layoffs_data;

-- insert data into staging table

INSERT layoffs_data_staging
SELECT * FROM layoffs_data;

SELECT * FROM layoffs_data_staging;

-- -------------  Data Cleaning ------------- 
-- Step 1. Remove Unnecessary Columns 

-- source, date_added and list-of-employees_laid_off columns might not be necessary, since they are not relavant to the layoffs analysis. Therefore, we can remove these columns from the table.
ALTER TABLE layoffs_data_staging
DROP COLUMN `Source`,
DROP COLUMN Date_Added,
DROP COLUMN List_of_Employees_Laid_Off;

SELECT * FROM layoffs_data_staging;


-- Step 2. Remove Duplicates
-- checking for duplicates
SELECT Company, Location_HQ, Industry, Country, Laid_Off_Count, `Date`,
		ROW_NUMBER() OVER(PARTITION BY Company, Location_HQ, Country) as row_num
FROM layoffs_data_staging;

-- selecting duplicate values parititioned by company, location_HQ and country
SELECT *
FROM (
		SELECT Company, Location_HQ, Country, Industry, Laid_Off_Count, `Date`,
		ROW_NUMBER() OVER(PARTITION BY Company, Location_HQ, Country) as row_num
        FROM layoffs_data_staging
	) AS duplicates

WHERE row_num > 1;

-- According to resule, there might be some duplicate values, So let's Look at some values for confirmation
SELECT *
FROM layoffs_data_staging
WHERE Company = 'Amazon';


-- As we check the data, there are no duplicate values, so let's just paritiion this table over date and laid_off_count too.
SELECT *
FROM (
		SELECT Company, Location_HQ, Country, Industry, Laid_Off_Count, `Date`,
		ROW_NUMBER() OVER(PARTITION BY Company, Location_HQ, Country, `Date`, Laid_Off_Count) as row_num
        FROM layoffs_data_staging
	) AS duplicates

WHERE row_num > 1;


-- Again, there might be some more duplicate values, let's take a look at them.

SELECT * 
FROM layoffs_data_staging
WHERE Company = 'Oda';


-- We can see some are not duplicate values, as the funds_raised and percentage column values are different for Oda Compnany. So, let's parition over them too...
SELECT *
FROM (
		SELECT Company, Location_HQ, Country, Industry, Laid_Off_Count, `Date`,
		ROW_NUMBER() OVER(PARTITION BY Company, Location_HQ, Country, `Date`, Laid_Off_Count, Funds_Raised, Percentage) as row_num
        FROM layoffs_data_staging
	) AS duplicates

WHERE row_num > 1;


-- Or MAYBE you can partition over everything... Like this...
-- SELECT *
-- FROM (
-- 		SELECT Company, Location_HQ, Country, Industry, Laid_Off_Count, `Date`,
-- 		ROW_NUMBER() OVER(PARTITION BY Company, Location_HQ, Industry, Country, `Date`, Laid_Off_Count, Funds_Raised, Percentage, Stage) as row_num
--         FROM layoffs_data_staging
-- 	) AS duplicates

-- WHERE row_num > 1;

-- Any Way we got same result for duplicate values...
-- Let's Look at duplicate values

SELECT * 
FROM layoffs_data_staging
WHERE Company = 'Beyond Meat';

-- As we can observe, these are duplicate values in the data, where Cazoo and Beyond Meat are the Companies...
-- Now, Let's remove/delete these duplicate values from the table

-- As we cannot directly remove these duplicate rows, let's just create a new table called layoffs_data_staging1 with same structure as layoffs_data_stagin with an extra column as row_num to this staging1 table. Then, remove the rows with row_num greater than 1 from this table.

CREATE TABLE layoffs_data_staging1(
Company TEXT,
Location_HQ TEXT,
Industry TEXT,
Laid_Off_Count TEXT,
Date TEXT,
Funds_Raised TEXT,
Stage TEXT,
Country TEXT,
Percentage TEXT,
ROW_NUM INT
);


INSERT INTO layoffs_data_staging1
(
Company,
Location_HQ,
Industry,
Laid_Off_Count,
`Date`,
Funds_Raised,
Stage,
Country,
Percentage,
ROW_NUM
)
SELECT 
Company,
Location_HQ,
Industry,
Laid_Off_Count,
`Date`,
Funds_Raised,
Stage,
Country,
Percentage,
	ROW_NUMBER() OVER(PARTITION BY Company, Location_HQ, Country, `Date`, Laid_Off_Count, Funds_Raised, Percentage) as ROW_NUM
FROM layoffs_data_staging;

select count(*) from layoffs_data_staging1;


-- Now, We can delete/remove the duplicate values from this table using DELETE command
DELETE FROM layoffs_data_staging1
WHERE ROW_NUM > 1;

SELECT * FROM layoffs_data_staging1;

-- Now, as duplicates are removed, let's move on to next step


-- Step 3. Standardize Data

-- Let's normalize text data by removing white spaces in columns if any
SELECT DISTINCT Company
FROM layoffs_data_staging1
ORDER BY 1;

-- As it can be observed that, some companies has leading spaces. Let's just trim them
UPDATE layoffs_data_staging1
SET Company = TRIM(Company);

-- The Data type of Laid_Off_Count, Funds_Raised should be int and Percentage should be decimal or float. Let's change them from text to appropriate data type. 
-- For this, we need to update the empty values to NULL in these columns
UPDATE layoffs_data_staging1
SET Laid_Off_Count = NULL
WHERE Laid_Off_Count = '';

UPDATE layoffs_data_staging1
SET Funds_Raised = NULL
WHERE Funds_Raised = '';

UPDATE layoffs_data_staging1
SET Percentage = NULL
WHERE Percentage = '';

-- Now, modifying columns type accordingly...
ALTER TABLE layoffs_data_staging1
MODIFY Laid_Off_Count INT,
MODIFY Funds_Raised INT,
MODIFY Percentage DECIMAL(7,5);

SELECT * FROM layoffs_data_staging1;

--  Fixing Date column STR_TO_DATE can be used to modify date field from text to date
-- Updating field values
UPDATE layoffs_data_staging1
SET `Date` = STR_TO_DATE(`Date`, '%d-%m-%Y');

-- Changing data type of date column
ALTER TABLE layoffs_data_staging1
MODIFY COLUMN `Date` DATE;

SELECT * FROM layoffs_data_staging1;

-- Location_HQ and Industry has unknown values
-- Industry has Other values more in number than unknown (which is only one)
-- Changing 'Unknown' values in the 'Industry' column to 'Other' to consolidate unspecified categories
-- This simplifies analysis by grouping all undefined or unspecified industries under 'Other'
-- Helps ensure consistency and prevents potential confusion between 'Unknown' and 'Other'
UPDATE layoffs_data_staging1
SET Industry = 'Other'
WHERE Industry = 'Unknown';


-- The unknown value in Location_HQ may not be modified as there are no other suitable values
-- The 'Location_HQ' column contains a single 'Unknown' value
-- Since there is no additional information available to populate this field, the 'Unknown' value will be left as it is
-- No suitable replacement or category (such as 'Other') is available for this case



-- Next Step will be looking at null values if any
-- Step 4. Looking at NULL values
SELECT * FROM layoffs_data_staging1
WHERE Laid_Off_Count IS NULL;

SELECT * FROM layoffs_data_staging1
WHERE Funds_Raised IS NULL;

SELECT * FROM layoffs_data_staging1
WHERE Percentage IS NULL;

-- There are NULL values in Laid_Off_Count, Funds_Raised, Percentage columns. But, we isn't really anything to change these values since they are looking normal


-- Final Step we are going to do in this Data Cleaning Project is to remove unwanted rows and columns if any.

-- Step 5. Removing unwanted Columns and Rows if any
-- The ROW_NUM column we created for deleting/removing duplicate values is unnecessary now and this can be removed.
ALTER TABLE layoffs_data_staging1
DROP COLUMN ROW_NUM;

SELECT * FROM layoffs_data_staging1;


-- As some values are missing in Laid_Off_Count, Funds_Raised and Percentage columns, for analysing this layoffs data, we don't use them since they are null or missing values 
-- This data is useless for analysis. Therefore, we can delete data we don't use...
-- Deleting rows where Laid_Off_Count and Percentage fields are null
SELECT * FROM layoffs_data_staging1
WHERE Laid_Off_Count IS NULL
AND
Percentage IS NULL;

DELETE FROM layoffs_data_staging1
WHERE Laid_Off_Count IS NULL
AND
Percentage IS NULL;

SELECT * FROM layoffs_data_staging1;


-- This cleaned dataset is now prepared for further exploratory data analysis (EDA), ensuring consistency, 
-- completeness, and accuracy in the data. The project emphasized thoughtful handling of missing data, 
-- with a focus on maintaining the relevance and integrity of the layoffs dataset.


















