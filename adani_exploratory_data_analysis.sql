-- Exploratory Data Analysis (EDA) on Adani Stock Data

-- Step 1: Check the total number of records in the dataset
SELECT COUNT(*) AS total_records FROM tweets.adani_staging;

-- Step 2: View the first few records to understand the data structure
SELECT * FROM tweets.adani_staging LIMIT 10;

-- Step 3: Get column names and data types
DESCRIBE tweets.adani_staging;

-- Step 4: Identify the range of dates in the dataset
SELECT MIN(`timestamp`) AS start_date, MAX(`timestamp`) AS end_date
FROM tweets.adani_staging;

-- Step 5: Check for NULL values in each column
SELECT 
    SUM(CASE WHEN `timestamp` IS NULL THEN 1 ELSE 0 END) AS null_timestamps,
    SUM(CASE WHEN symbol IS NULL THEN 1 ELSE 0 END) AS null_symbols,
    SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS null_companies,
    SUM(CASE WHEN `open` IS NULL THEN 1 ELSE 0 END) AS null_open,
    SUM(CASE WHEN high IS NULL THEN 1 ELSE 0 END) AS null_high,
    SUM(CASE WHEN low IS NULL THEN 1 ELSE 0 END) AS null_low,
    SUM(CASE WHEN `close` IS NULL THEN 1 ELSE 0 END) AS null_close,
    SUM(CASE WHEN volume IS NULL THEN 1 ELSE 0 END) AS null_volume,
    SUM(CASE WHEN dividends IS NULL THEN 1 ELSE 0 END) AS null_dividends,
    SUM(CASE WHEN stock_splits IS NULL THEN 1 ELSE 0 END) AS null_stock_splits
FROM tweets.adani_staging;

-- Step 6: Identify unique companies and symbols in the dataset
SELECT DISTINCT company, symbol FROM tweets.adani_staging;

-- Step 7: Find the number of occurrences for each company
SELECT company, COUNT(*) AS record_count
FROM tweets.adani_staging
GROUP BY company
ORDER BY record_count DESC;

-- Step 8: Find duplicate records (if any)
SELECT `timestamp`, symbol, company, COUNT(*) AS duplicate_count
FROM tweets.adani_staging
GROUP BY `timestamp`, symbol, company, `open`, high, low, `close`, volume, dividends, stock_splits
HAVING COUNT(*) > 1;

-- Step 9: Get summary statistics for numeric columns (min, max, avg, stddev)
SELECT 
    MIN(`open`) AS min_open, MAX(`open`) AS max_open, AVG(`open`) AS avg_open, STDDEV(`open`) AS stddev_open,
    MIN(high) AS min_high, MAX(high) AS max_high, AVG(high) AS avg_high, STDDEV(high) AS stddev_high,
    MIN(low) AS min_low, MAX(low) AS max_low, AVG(low) AS avg_low, STDDEV(low) AS stddev_low,
    MIN(`close`) AS min_close, MAX(`close`) AS max_close, AVG(`close`) AS avg_close, STDDEV(`close`) AS stddev_close,
    MIN(volume) AS min_volume, MAX(volume) AS max_volume, AVG(volume) AS avg_volume, STDDEV(volume) AS stddev_volume
FROM tweets.adani_staging;

-- Step 10: Identify any outliers in stock prices (values significantly different from the average)
SELECT *
FROM tweets.adani_staging
WHERE `close` > (SELECT AVG(`close`) + 3 * STDDEV(`close`) FROM tweets.adani_staging)
   OR `close` < (SELECT AVG(`close`) - 3 * STDDEV(`close`) FROM tweets.adani_staging);

-- Step 11: Analyze stock price trends by month
SELECT 
    DATE_FORMAT(FROM_UNIXTIME(`timestamp`), '%Y-%m') AS month, 
    AVG(`close`) AS avg_closing_price, 
    MAX(`close`) AS max_closing_price, 
    MIN(`close`) AS min_closing_price
FROM tweets.adani_staging
GROUP BY month
ORDER BY month;

-- Step 12: Identify the most volatile stocks (largest difference between high and low)
SELECT symbol, company, 
       MAX(high - low) AS max_price_difference
FROM tweets.adani_staging
GROUP BY symbol, company
ORDER BY max_price_difference DESC
LIMIT 10;

-- Step 13: Find the trading days with the highest volume
SELECT `timestamp`, symbol, company, volume
FROM tweets.adani_staging
ORDER BY volume DESC
LIMIT 10;

-- Step 14: Check for missing dates in the dataset
SELECT `timestamp`
FROM tweets.adani_staging
ORDER BY `timestamp`;

-- Step 15: Analyze correlation between stock price and trading volume
SELECT 
    CORR(`close`, volume) AS correlation_close_volume,
    CORR(`open`, volume) AS correlation_open_volume
FROM tweets.adani_staging;

-- Step 16: Identify the most frequent opening prices
SELECT `open`, COUNT(*) AS frequency
FROM tweets.adani_staging
GROUP BY `open`
ORDER BY frequency DESC
LIMIT 10;

-- Step 17: Check stock splits occurrence
SELECT COUNT(*) AS stock_splits_count
FROM tweets.adani_staging
WHERE stock_splits > 0;

-- Step 18: Identify the most frequently occurring stock symbols
SELECT symbol, COUNT(*) AS occurrence_count
FROM tweets.adani_staging
GROUP BY symbol
ORDER BY occurrence_count DESC;

-- Step 19: Detect any negative values in numeric columns (which might indicate data errors)
SELECT *
FROM tweets.adani_staging
WHERE `open` < 0 OR high < 0 OR low < 0 OR `close` < 0 OR volume < 0 OR dividends < 0 OR stock_splits < 0;

-- Step 20: Get a time-series overview of stock performance for a specific company
SELECT FROM_UNIXTIME(`timestamp`) AS trade_date, `close`
FROM tweets.adani_staging
WHERE symbol = 'ADANIPORTS'
ORDER BY trade_date;

-- Step 21: Identify consecutive days with the highest percentage increase in closing price
SELECT symbol, company, `timestamp`,
       `close` AS closing_price,
       LAG(`close`) OVER (PARTITION BY symbol ORDER BY `timestamp`) AS prev_closing_price,
       ROUND((( `close` - LAG(`close`) OVER (PARTITION BY symbol ORDER BY `timestamp`) ) / LAG(`close`) OVER (PARTITION BY symbol ORDER BY `timestamp`) ) * 100, 2) AS daily_percentage_change
FROM tweets.adani_staging
ORDER BY daily_percentage_change DESC
LIMIT 10;

-- Step 22: Find the days with the highest percentage decrease in closing price
SELECT symbol, company, `timestamp`,
       `close` AS closing_price,
       LAG(`close`) OVER (PARTITION BY symbol ORDER BY `timestamp`) AS prev_closing_price,
       ROUND((( `close` - LAG(`close`) OVER (PARTITION BY symbol ORDER BY `timestamp`) ) / LAG(`close`) OVER (PARTITION BY symbol ORDER BY `timestamp`) ) * 100, 2) AS daily_percentage_change
FROM tweets.adani_staging
ORDER BY daily_percentage_change ASC
LIMIT 10;

-- Step 23: Compute the average daily price range (difference between high and low) for each stock
SELECT symbol, company,
       AVG(high - low) AS avg_daily_range
FROM tweets.adani_staging
GROUP BY symbol, company
ORDER BY avg_daily_range DESC;

-- Step 24: Identify stocks with the highest standard deviation in closing price (indicating volatility)
SELECT symbol, company,
       STDDEV(`close`) AS closing_price_volatility
FROM tweets.adani_staging
GROUP BY symbol, company
ORDER BY closing_price_volatility DESC
LIMIT 10;

-- Step 25: Find the month with the highest average trading volume
SELECT DATE_FORMAT(FROM_UNIXTIME(`timestamp`), '%Y-%m') AS month,
       AVG(volume) AS avg_trading_volume
FROM tweets.adani_staging
GROUP BY month
ORDER BY avg_trading_volume DESC
LIMIT 1;

-- Step 26: Analyze the impact of stock splits on closing price
SELECT symbol, company, `timestamp`,
       stock_splits,
       LAG(`close`) OVER (PARTITION BY symbol ORDER BY `timestamp`) AS prev_closing_price,
       `close` AS new_closing_price,
       ROUND((( `close` - LAG(`close`) OVER (PARTITION BY symbol ORDER BY `timestamp`) ) / LAG(`close`) OVER (PARTITION BY symbol ORDER BY `timestamp`) ) * 100, 2) AS price_change_percentage
FROM tweets.adani_staging
WHERE stock_splits > 0
ORDER BY `timestamp`;

-- Step 27: Check if higher dividends correlate with stock price increases
SELECT 
    CORR(dividends, `close`) AS correlation_dividends_closing_price
FROM tweets.adani_staging;

-- Step 28: Identify the highest price gap between the opening and closing price on a single day
SELECT symbol, company, `timestamp`,
       (`close` - `open`) AS price_gap
FROM tweets.adani_staging
ORDER BY price_gap DESC
LIMIT 10;

-- Step 29: Analyze the performance of stocks in the first and second half of the year
SELECT symbol, company,
       AVG(CASE WHEN MONTH(FROM_UNIXTIME(`timestamp`)) <= 6 THEN `close` END) AS avg_price_first_half,
       AVG(CASE WHEN MONTH(FROM_UNIXTIME(`timestamp`)) > 6 THEN `close` END) AS avg_price_second_half
FROM tweets.adani_staging
GROUP BY symbol, company;

-- Step 30: Find stocks with the most consistent price movements (lowest standard deviation)
SELECT symbol, company,
       STDDEV(`close`) AS closing_price_consistency
FROM tweets.adani_staging
GROUP BY symbol, company
ORDER BY closing_price_consistency ASC
LIMIT 10;
