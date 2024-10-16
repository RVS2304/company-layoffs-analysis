-- The original data is stored in the 'layoffs_data' table.
-- After creating a staging table, necessary data cleaning and transformations were performed.
-- The final cleaned data is stored in the 'layoffs_data_staging1' table.
-- The 'layoffs_data_staging1' table will now be used for Exploratory Data Analysis (EDA) to ensure the analysis is performed on
--  clean and accurate data.


-- Let's perform EDA on layoffs_data_staging1 table.

-- 1. Understanding the structure of data
DESC layoffs_data_staging1;

-- After data cleaning phase, the columns Laid_Off_Count, Date, Funds_Raised and Percentage are set to corresponding data types accordingly.


-- 2. Descriptive Statistics
SELECT COUNT(*) FROM layoffs_data;
SELECT COUNT(*) FROM layoffs_data_staging1; 
-- Original data has about 3642 rows. After data cleaning (removing useless rows where Laid_Off_Count and Percentage are null values), 
-- the dataset now has 3041 rows, ensuring that only relevant and analyzable data is retained.

-- Count of Unique companies
SELECT COUNT(DISTINCT Company) FROM layoffs_data_staging1;

-- Count of Unique Industries
SELECT COUNT(DISTINCT Industry) FROM layoffs_data_staging1;

-- Summary statistics for numerical columns
SELECT
	AVG(Laid_Off_Count) AS Avg_Laid_Off_Count,
	MIN(Laid_Off_Count) AS Min_Laid_Off_Count,
	MAX(Laid_Off_Count) AS Max_Laid_Off_Count,
	AVG(Funds_Raised) AS Avg_Funds_Raised,
	MIN(Funds_Raised) AS Min_Funds_Raised,
	MAX(Funds_Raised) AS Max_Funds_Raised,
	AVG(Percentage) AS Avg_Percentage,
	MIN(Percentage) AS Min_Percentage,
	MAX(Percentage) AS Max_Percentage
FROM layoffs_data_staging1;

-- The minimun laid_off_count is 3 and maximum is 14000


 -- Let's look at timeline of the data
 WITH TimeLineCTE AS (
	SELECT MIN(`Date`) AS Start_Date, MAX(`Date`) AS End_Date
	FROM layoffs_data_staging1
)
SELECT 
TIMESTAMPDIFF(YEAR, Start_Date, End_Date) AS Years,
TIMESTAMPDIFF(MONTH, Start_Date, End_Date)%12 AS Months,
DATEDIFF(end_date, DATE_ADD(start_date, INTERVAL TIMESTAMPDIFF(MONTH, start_date, end_date) MONTH)) AS days
FROM TimelineCTE
;

-- With in the time line that is about nearly 4.3 years let's analyze layoffs data..

-- Companies with the biggest single Layoff
SELECT Company, Laid_Off_Count, `Date`
FROM layoffs_data_staging1
ORDER BY 2 DESC
LIMIT 10;

-- Analyzing layoffs over the years
SELECT 
    YEAR(`Date`) AS `Year`, 
    SUM(Laid_Off_Count) AS Total_Laid_Off
FROM layoffs_data_staging1
GROUP BY `Year`
ORDER BY 2 desc;

-- 2021 has minimum layoffs and, 2023 has maximum layoffs

-- Analyzing layoffs over the years and months
SELECT YEAR(Date) AS Year, MONTH(Date) AS Month, SUM(Laid_Off_Count) AS Total_Laid_Off
FROM layoffs_data_staging1
GROUP BY Year, Month
ORDER BY Year, Month;


-- * Count of layoffs by company *
SELECT Company, SUM(Laid_Off_Count) AS Count_Of_Layoffs 
FROM layoffs_data_staging1
GROUP BY Company
ORDER BY 2 DESC;

-- Amazon has most layoffs followed by Meta, Tesla, microsoft and Google


-- Top 10 companies with most layoffs
SELECT Company, SUM(Laid_Off_Count) AS Count_Of_Layoffs 
FROM layoffs_data_staging1
GROUP BY Company
ORDER BY 2 DESC
LIMIT 10;


-- * Count of layoffs by Industry *
SELECT Industry, SUM(Laid_Off_Count) AS Count_Of_Layoffs 
FROM layoffs_data_staging1
GROUP BY Industry
ORDER BY 2 DESC;

-- Highest layoffs hapened in Retail Industry


-- Top 10 Industries with most layoffs
SELECT Industry, SUM(Laid_Off_Count) AS Count_Of_Layoffs 
FROM layoffs_data_staging1
GROUP BY Industry
ORDER BY 2 DESC
LIMIT 10;

SELECT Industry, SUM(Laid_Off_Count) AS Count_Of_Layoffs 
FROM layoffs_data_staging1
GROUP BY Industry
ORDER BY 2;
-- Least Layoffs happened in AI industry


-- * Count of layoffs by Country *
SELECT Country, SUM(Laid_Off_Count) AS Count_Of_Layoffs 
FROM layoffs_data_staging1
GROUP BY Country
ORDER BY 2 DESC;

-- Highest layoffs hapened in United States followed by India, Germany, UK and Netherlands


-- Top 10 Countries with most layoffs
SELECT Country, SUM(Laid_Off_Count) AS Count_Of_Layoffs 
FROM layoffs_data_staging1
GROUP BY Country
ORDER BY 2 DESC
LIMIT 10;


-- * Count of layoffs by Stage *
SELECT Stage, SUM(Laid_Off_Count) AS Count_Of_Layoffs 
FROM layoffs_data_staging1
GROUP BY Stage
ORDER BY 2 DESC;



-- Calculating the total laid off employees per company per year.
SELECT Company, Years, Total_Laid_Off, Ranking
FROM (
  -- Calculates total layoffs for each company in each year.
  SELECT Company, YEAR(`Date`) AS Years, SUM(Laid_Off_Count) AS Total_Laid_Off,
         -- Use DENSE_RANK to rank companies within each year by total layoffs.
         DENSE_RANK() OVER (PARTITION BY YEAR(`Date`) ORDER BY SUM(Laid_Off_Count) DESC) AS Ranking
  FROM layoffs_data_staging1
  GROUP BY Company, YEAR(`Date`)
) AS RankedCompanies
WHERE Ranking <= 3
AND Years IS NOT NULL
ORDER BY Years ASC, Total_Laid_Off DESC;



SELECT Company, MAX(Percentage) AS Max_Percentage_Laid_Off
FROM layoffs_data_staging1
GROUP BY Company
ORDER BY Max_Percentage_Laid_Off DESC
LIMIT 10;



-- Correlation between Laid_Off_Count and Funds_Raised
SELECT 
    Company,
    AVG(Funds_Raised) AS Avg_Funds_Raised, 
    AVG(Laid_Off_Count) AS Avg_Laid_Off_Count
FROM layoffs_data_staging1
GROUP BY Company
HAVING Avg_Funds_Raised IS NOT NULL AND Avg_Laid_Off_Count IS NOT NULL;


-- Looking at companies where percentageis 1, that is 100% of company is laid off
SELECT Company
FROM layoffs_data_staging1
WHERE Percentage = 1;

-- Looking at funds_raised where laid off percentage is 1 that is 100%
SELECT Company, SUM(Percentage), SUM(Funds_Raised) AS Total_Funds_Raised
FROM layoffs_data_staging1
WHERE Percentage = 1
GROUP BY Company
ORDER BY Total_Funds_Raised desc;





