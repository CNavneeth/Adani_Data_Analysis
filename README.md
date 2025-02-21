# 📊 Adani Stock Data - Data Cleaning & Exploratory Data Analysis (EDA)

## **Project Overview**
This project focuses on **Data Cleaning** and **Exploratory Data Analysis (EDA)** for Adani stock data.  
The dataset contains stock market information such as opening price, closing price, high, low, volume, and more.  

Data cleaning ensures accuracy and consistency, while EDA helps uncover patterns, trends, and insights from the data.  

---

## **🛠 Tech Stack Used**
- **SQL** (MySQL / PostgreSQL)  

---

## **📌 Dataset Description**
The dataset contains the following columns:  
- `timestamp`: The date and time of stock data collection  
- `symbol`: The stock symbol  
- `company`: The company name  
- `open`: Opening price  
- `high`: Highest price of the day  
- `low`: Lowest price of the day  
- `close`: Closing price  
- `volume`: Number of shares traded  
- `dividends`: Dividend value  
- `stock_splits`: Stock split data  

---

# **🧼 Data Cleaning Process**
The following steps were performed to clean the data:  

### **1️⃣ Create a Staging Table**
- A copy of the original table is made to preserve raw data.  

### **2️⃣ Check for Duplicates & Remove Them**
- Identified duplicates using `ROW_NUMBER()` function.  
- Deleted duplicate records while keeping the first occurrence.  

### **3️⃣ Standardizing Text Data**
- Trimmed whitespace from text columns.  
- Standardized company names and stock symbols for consistency.  

### **4️⃣ Handling Null Values**
- Replaced missing numerical values with `0`.  
- Replaced missing text values with `"Unknown"`.  
- Deleted records with critical missing values (`timestamp`, `symbol`, `company`).  

### **5️⃣ Date Format Standardization**
- Converted dates into standard SQL format (`YYYY-MM-DD`).  

### **6️⃣ Final Check**
- Ensured all transformations were applied correctly.  

---

# **📊 Exploratory Data Analysis (EDA)**
After cleaning, EDA was performed to analyze stock trends and patterns.  

### **1️⃣ Checking Basic Statistics**
- Counted the number of records, missing values, and distinct values.  

### **2️⃣ Stock Price Distribution**
- Calculated **minimum, maximum, mean, and median** for `open`, `close`, `high`, and `low` prices.  

### **3️⃣ Stock Performance Over Time**
- Identified top-performing stocks based on highest average closing price.  

### **4️⃣ Most Volatile Stocks**
- Used standard deviation to measure volatility in stock prices.  

### **5️⃣ Trading Volume Analysis**
- Identified days with highest and lowest trading volume.  

### **6️⃣ Yearly Trends**
- Grouped stock data by year to analyze long-term trends.  

### **7️⃣ Correlation Between Prices**
- Checked if `open`, `close`, `high`, and `low` prices are correlated.  

### **8️⃣ Impact of Dividends & Stock Splits**
- Analyzed how dividends and stock splits affected stock prices.  

### **9️⃣ Identifying Outliers**
- Used interquartile range (IQR) to detect extreme stock price values.  

### **🔟 Final Summary**
- Summarized key insights from EDA.  

---

# 📂 **Project Files**
- **`adani_data_cleaning_script.sql`** → SQL script for data cleaning
- **`Adani_Stock_Data_Cleaning.txt`** → Full Data Cleaning report
- **`adani_exploratory_data_analysis.sql`** → SQL script for EDA  
- **`Adani_Stock_EDA_Report.txt`** → Full EDA report  
- **`adani.csv.txt`** → Dataset

---

