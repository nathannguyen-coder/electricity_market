# U.S. Electricity Market Price Volatility Analysis

## Overview
This project analyzes wholesale electricity price volatility across two major U.S. power markets: **PJM** and **MISO**. Since both markets use **Locational Marginal Pricing (LMP)**, they provide a strong basis for comparison across time, seasonality, and operating conditions.

The goal of the project is to help market participants understand:
- when and where electricity prices spike,
- how volatility differs between PJM and MISO,
- which operational factors are associated with higher prices, and
- how these patterns can support better market monitoring and decision-making.

This end-to-end analytics project includes:
- loading and exploring the dataset in Python,
- cleaning and preparing the data,
- querying the data in MySQL,
- building an interactive Power BI dashboard,
- and summarizing insights in a final report.

---

## Business Problem
Wholesale electricity prices in U.S. power markets are highly volatile across time and locations. Market participants need a way to identify when and where prices spike, understand the operational patterns behind that volatility, and monitor differences between major markets such as PJM and MISO.

### Core Analytics Question
**How do electricity prices vary by market, time of day, season, and location, and what patterns could help market participants better monitor volatility and make market decisions?**

---

## Dataset
This project uses the **Electricity Market Data (United States)** dataset from Kaggle, which includes time-series electricity market data for **PJM** and **MISO**. The dataset contains 5 years of data in 15-minute intervals and includes pricing and operational variables used to study market behavior.

### Data Source
- **Kaggle:** *Electricity Market Data (United States)*
- **Author:** jaredandreatta
- **Link:** add your Kaggle dataset URL here

### Included Variables
The dataset includes variables related to:
- Real-time LMP prices
- Day-ahead LMP prices
- Load levels
- Generation mix (gas, coal, nuclear, hydro)
- Ramp imports and exports
- Date and time fields
- On-peak vs off-peak indicators
- Weekday vs weekend structure

These features allow for both market comparison and operational analysis of price volatility.

---

## Tools Used
- **Python** — data loading, exploratory data analysis (EDA), and cleaning
- **Pandas / NumPy / Matplotlib / Seaborn** — data manipulation and visualization
- **MySQL** — structured querying and business analysis
- **Power BI** — interactive dashboard creation
- **Jupyter Notebook** — workflow documentation and analysis
- **GitHub** — project version control and presentation

---

## Project Workflow

### 1. Data Loading in Python
The dataset was first loaded into Python using Jupyter Notebook. Initial checks were performed to understand:
- dataset size,
- column names,
- data types,
- missing values,
- and basic descriptive statistics.

### 2. Exploratory Data Analysis (EDA)
EDA was performed to identify major pricing trends and data quality issues. Key areas explored included:
- average price differences between PJM and MISO,
- volatility of each market,
- hourly price patterns,
- seasonal patterns,
- and relationships between price and system load or generation variables.

### 3. Data Cleaning
The dataset was cleaned to improve consistency and usability for SQL and dashboard analysis. Cleaning steps included:
- converting date/time fields into usable datetime format,
- handling missing values,
- standardizing numeric columns,
- removing formatting issues such as commas in numeric fields,
- and preparing fields for time-based grouping.

### 4. SQL Analysis in MySQL
After cleaning, the data was loaded into MySQL for structured analysis. SQL queries were used to answer business-focused questions such as:
- Which market has the higher average price?
- Which market is more volatile?
- How do prices vary by hour of day?
- Are on-peak hours more expensive than off-peak hours?
- Which season is most expensive and volatile?
- How do weekday and weekend prices differ?
- Are higher loads associated with higher prices?
- Do ramp imports and exports signal price stress?
- How do real-time prices compare to day-ahead prices?

The SQL workflow for this project is documented in `market.sql`.

### 5. Power BI Dashboard
A Power BI dashboard was built to present the analysis in an interactive and business-friendly format. The dashboard allows users to monitor:
- market-level price differences,
- hourly and monthly trends,
- volatility patterns,
- operational drivers such as load and generation,
- and price stress indicators.

### 6. Final Report
A final report was created to summarize the business problem, methodology, key findings, and recommendations. This report translates technical analysis into practical takeaways for market participants.

---

## Dashboard Overview
The Power BI dashboard is designed to answer the core business question through clear visual summaries.

### Market Overview
- Average real-time price in PJM vs MISO
- Price volatility comparison
- Total observation count / hours analyzed

### Time-Based Trends
- Average prices by hour of day
- Monthly average price trends
- Seasonal price and volatility comparison
- Weekday vs weekend pricing

### Operational Drivers
- Price by load bucket
- Price by gas generation bucket
- Price by ramp import/export bucket
- Real-time vs day-ahead market spread

### Volatility Monitoring
- Largest hourly price jumps
- Time periods associated with unusual price movement
- Stress indicators from ramping behavior or market conditions

---

## Key Results
Some of the main findings from the SQL analysis include:
- **PJM had a slightly higher average real-time price** than MISO.
- **PJM also showed higher price volatility**, suggesting larger price swings.
- Electricity prices varied significantly by **hour of day**, supporting the importance of intraday monitoring.
- **On-peak periods** tended to be more expensive than off-peak periods.
- Seasonal patterns showed that some times of year were both **more expensive and more volatile** than others.
- Operational variables such as **load, gas generation, and ramp activity** were useful for understanding price stress conditions.
- Comparing **real-time vs day-ahead prices** helped highlight periods where actual conditions differed from expected market conditions.

---

## Repository Structure
```bash
├── Electricity_Market_US_Project_fixed.ipynb   # Python data loading, EDA, and cleaning
├── market.sql                                  # MySQL queries for business analysis
├── Market.pbix                                 # Power BI dashboard
├── README.md                                   # Project documentation
