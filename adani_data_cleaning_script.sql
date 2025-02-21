-- SQL Project - Data Cleaning for Adani Stock Data

-- Step 1: Retrieve all records from the original table
SELECT * 
FROM tweets.adani;

-- Step 2: Create a staging table to work with, keeping raw data intact
CREATE TABLE tweets.adani_staging 
LIKE tweets.adani;

-- Step 3: Copy all data from the original table into the staging table
INSERT INTO tweets.adani_staging 
SELECT * FROM tweets.adani;

-- Step 4: Verify that data has been copied correctly
SELECT * 
FROM tweets.adani_staging;

-- Step 5: Check for duplicate records using ROW_NUMBER()
SELECT company, symbol, open, close, timestamp,
       ROW_NUMBER() OVER (
           PARTITION BY company, symbol, open, close, timestamp) AS row_num
FROM adani_staging;

-- Step 6: Identify duplicate records where row_num > 1
SELECT *
FROM (
    SELECT company, symbol, open, close, timestamp,
           ROW_NUMBER() OVER (
               PARTITION BY company, symbol, open, close, timestamp
           ) AS row_num
    FROM adani_staging
) duplicates
WHERE row_num > 1;

-- Step 7: Identify duplicates with all columns included for accuracy
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY `timestamp`, symbol, company, `open`, high, low, `close`, volume, dividends, stock_splits
           ) AS row_num
    FROM adani_staging
) duplicates
WHERE row_num > 1;

-- Step 8: Create a table to store duplicates for further analysis
CREATE TABLE `adani_staging_duplicates` (
  `timestamp` BIGINT DEFAULT NULL,
  `symbol` TEXT,
  `company` TEXT,
  `open` DOUBLE DEFAULT NULL,
  `high` DOUBLE DEFAULT NULL,
  `low` DOUBLE DEFAULT NULL,
  `close` DOUBLE DEFAULT NULL,
  `volume` INT DEFAULT NULL,
  `dividends` DOUBLE DEFAULT NULL,
  `stock_splits` DOUBLE DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 9: Clear any existing data in the duplicates table (if any)
TRUNCATE TABLE adani_staging_duplicates;

-- Step 10: Insert duplicate records into the duplicates table
INSERT INTO adani_staging_duplicates
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY `timestamp`, symbol, company, `open`, high, low, `close`, volume, dividends, stock_splits
           ) AS row_num
    FROM adani_staging
) duplicates;

-- Step 11: Delete extra duplicate records (keeping the first occurrence)
DELETE FROM adani_staging_duplicates
WHERE row_num > 1;

-- Step 12: Verify that duplicates have been removed
SELECT * 
FROM tweets.adani_staging_duplicates 
WHERE row_num > 1;

-- Step 13: Verify the remaining cleaned data
SELECT * 
FROM tweets.adani_staging_duplicates;

-- Step 14: Standardize the symbol column by trimming whitespace
UPDATE adani_staging_duplicates
SET symbol = TRIM(symbol);

-- Step 15: Check for distinct company names to identify inconsistencies
SELECT DISTINCT company 
FROM adani_staging_duplicates;

-- Step 16: Standardize naming conventions for company symbols
UPDATE adani_staging_duplicates 
SET symbol = 'ADANIPORTS'
WHERE symbol LIKE 'ADANIGREEN';

-- Step 17: Standardize company names for consistency
UPDATE adani_staging_duplicates 
SET company = 'Adani Ports'
WHERE company LIKE 'Adani Green';

-- Step 18: Convert date format to standard SQL date format
UPDATE adani_staging_duplicates
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Step 19: Remove NULL values from numeric columns by replacing them with 0
UPDATE adani_staging_duplicates 
SET open = COALESCE(open, 0),
    high = COALESCE(high, 0),
    low = COALESCE(low, 0),
    close = COALESCE(close, 0),
    volume = COALESCE(volume, 0),
    dividends = COALESCE(dividends, 0),
    stock_splits = COALESCE(stock_splits, 0);

-- Step 20: Remove NULL values from text columns by replacing them with 'Unknown'
UPDATE adani_staging_duplicates 
SET symbol = COALESCE(symbol, 'Unknown'),
    company = COALESCE(company, 'Unknown');

-- Step 21: Delete rows where critical fields (timestamp, symbol, company) are NULL
DELETE FROM adani_staging_duplicates 
WHERE `timestamp` IS NULL OR symbol IS NULL OR company IS NULL;

-- Step 22: Remove the row_num column as it's no longer needed
ALTER TABLE adani_staging_duplicates
DROP COLUMN row_num;

-- Step 23: Final check to ensure cleaned data is properly formatted
SELECT * 
FROM adani_staging_duplicates;
