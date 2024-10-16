# Data Cleaning and Exploratory Data Analysis (EDA) Using SQL -  company-layoffs-analysis
## Project Overview
This project focuses on data cleaning and exploratory data analysis (EDA) using SQL for a dataset related to company layoffs. The project is divided into two phases:
* Data Cleaning: Ensures the data is free from inconsistencies and inaccuracies.
* EDA: Extracts meaningful insights, identifies trends, and visualizes patterns in the cleaned data.

## Objective
The goal of this project is to:
* Clean the raw dataset to handle null values, duplicates, incorrect data types, and outliers.
* Analyze the cleaned dataset using SQL to uncover significant insights and trends related to company layoffs.

## Features
#### 1. Data Cleaning:
  * Handle missing or null values.
  * Remove duplicate entries.
  * Convert data types to match schema requirements.
  * Address outliers or inconsistencies.
#### 2. Exploratory Data Analysis:
  * Basic statistical summaries of key columns.
  * Trend analysis on layoffs across different sectors and time periods.
  * Identification of key factors influencing layoffs.
  * Aggregation and grouping to identify patterns.

## Technologies Used
* SQL: For data cleaning, analysis, and querying.

## Project Structure
* DataCleaning.sql: Contains SQL queries used to clean the dataset.
* EDA.sql: Contains SQL queries used for exploratory data analysis.

## How to Use
1. Clone the repository:
   git clone https://github.com/RVS2304/company-layoffs-analysis.git
2. Import the SQL scripts into your preferred SQL environment.
3. Execute the queries sequentially, starting with the data cleaning steps followed by the EDA queries.

## Key Insights
1. The dataset was cleaned to focus on relevant records, reducing the initial 3642 rows to 3041 rows.
2. The layoffs data spans approximately 4.3 years, with significant layoffs observed in the year 2023.
3. Amazon, Meta, and Tesla are the top companies with the highest layoffs, while industries such as Retail and Technology have been the most impacted.
4. The majority of layoffs occurred in the United States, followed by India and Germany.
5. Interesting patterns include companies with 100% layoffs, which warrants further investigation into business closures or restructuring.
6. A correlation analysis between Laid_Off_Count and Funds_Raised showed potential trends regarding company performance and layoff decisions.
7. The stage of company funding played a significant role in the number of layoffs, especially for companies in later funding stages.


---------------------------------------------------------------------------------------------------------------------------------------------------------

#### * Overall, this EDA has provided a thorough understanding of the trends, key players, and industries most affected by layoffs. 
#### * The findings could be useful for further analysis such as predictive modeling or deeper sectoral analysis.
#### * The clean data and EDA outputs are now ready for the next stages of analysis or presentation.

---------------------------------------------------------------------------------------------------------------------------------------------------------

