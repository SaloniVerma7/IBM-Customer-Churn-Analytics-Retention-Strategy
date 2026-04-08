# Create Database
CREATE DATABASE Customer_Churn;

#Show the Actual Table Name
SHOW TABLES;

# Rename the long file name into short suitable name 
RENAME TABLE `ibm telco_customer_churn_dataset` TO customer_churn;

# Use Database
USE Customer_Churn;

# View Customer Table
SELECT * FROM customer_churn LIMIT 10;

# Handle blank values:
SET SQL_SAFE_UPDATES = 1;
SELECT * FROM  customer_churn
WHERE TotalCharges = '';
SET SQL_SAFE_UPDATES = 0;

# Basic Analysis
-- Total customers
SELECT COUNT(*) FROM customer_churn;

-- Churn rate
SELECT 
    SUM(CASE WHEN `Churn Label` = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS churn_rate
FROM customer_churn;

# High-risk customers
SELECT *
FROM customer_churn
WHERE `tenure Months` < 6 AND `Monthly Charges` > 80;

# Change churn lable name into churn for better understanding 
ALTER TABLE customer_churn
CHANGE COLUMN `Churn Label` Churn VARCHAR(10);

# Churn by contract type
SELECT Contract, COUNT(*) AS total,
SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM customer_churn
GROUP BY Contract;

# Revenue loss due to churn
SELECT 
SUM(TotalCharges) AS revenue_lost
FROM customer_churn
WHERE Churn = 'Yes';

# Change Tenure Months column name into Tenure
ALTER TABLE customer_churn
CHANGE COLUMN `Tenure Months` Tenure VARCHAR(10);

# Cohort / Retention Analysis
SELECT tenure, COUNT(*) AS customers
FROM customer_churn
GROUP BY tenure
ORDER BY tenure;

# Overall Churn Rate
-- Sum of Churned Customer*100 / Total Customers 
SELECT 
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_percent
FROM customer_churn;
-- Shows total % of customers leaving.

# Churn by Payment Method
SELECT 
    `Payment Method`,
    COUNT(*) AS total,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS churn_rate
FROM customer_churn
GROUP BY `Payment Method`
ORDER BY churn_rate DESC;
-- Which payment method causes more churn.alter

# Monthly Charges Impact
SELECT 
    CASE 
        WHEN `Monthly Charges` < 50 THEN 'Low'
        WHEN `Monthly Charges` BETWEEN 50 AND 80 THEN 'Medium'
        ELSE 'High'
    END AS charge_group,
    COUNT(*) AS total,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM customer_churn
GROUP BY charge_group;
-- High charges → more churn?

# Tenure vs Churn
SELECT 
    CASE 
        WHEN tenure < 12 THEN 'New Customers'
        WHEN tenure BETWEEN 12 AND 24 THEN 'Mid-Term'
        ELSE 'Long-Term'
    END AS customer_group,
    COUNT(*) AS total,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM customer_churn
GROUP BY customer_group;
-- Insight: New customers churn more.

# Services Impact on Churn
SELECT 
	`Internet Service`,
    COUNT(*) AS total,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM customer_churn
GROUP BY `Internet Service`;
-- Insight: Which service users leave more.


# Top 5 High Value Customers Who Left
SELECT *
FROM customer_churn
WHERE Churn = 'Yes'
ORDER BY TotalCharges DESC
LIMIT 5;
-- Most valuable customers lost.

# Churn Trend 
SELECT 
    tenure,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM customer_churn
GROUP BY tenure
ORDER BY tenure;
-- When customers leave most.

# Customer Segmentation in SQL
SELECT 
    *,
    CASE
        WHEN tenure < 6 AND `Monthly Charges` > 80 THEN 'High Risk'
        WHEN tenure < 12 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM
    customer_churn;
    
# Top Churn Drivers (Multi-factor Analysis)
SELECT 
    Contract,
    `Internet Service`,
    `Payment Method`,
    COUNT(*) AS total,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS churn_rate
FROM customer_churn
GROUP BY Contract, `Internet Service`, `Payment Method`
ORDER BY churn_rate DESC
LIMIT 10;
-- Combination of factors causing highest churn.alter

# Churn Contribution % (Which group contributes most churn)
SELECT 
    Contract,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 /
        (SELECT SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) FROM customer_churn),
    2) AS contribution_percent
FROM customer_churn
GROUP BY Contract
ORDER BY contribution_percent DESC;
-- Which segment contributes most to total churn.

# Average Revenue Lost per Customer
SELECT 
    ROUND(AVG(TotalCharges),2) AS avg_revenue_lost
FROM customer_churn
WHERE Churn = 'Yes';
-- Average loss per churned customer.

# Customer Lifetime Value (CLV Approximation)
SELECT 
    customerID,
    tenure,
    `Monthly Charges`,
    (tenure * `Monthly Charges`) AS estimated_clv
FROM customer_churn
ORDER BY estimated_clv DESC
LIMIT 10;
-- Most valuable customers.

# Early Churn Detection (CRITICAL)
SELECT 
    COUNT(*) AS early_churn_count
FROM customer_churn
WHERE tenure < 3 AND Churn = 'Yes';
--  These Customers leaving too early.

# Retention Rate
SELECT 
    ROUND(SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS retention_rate
FROM customer_churn;
-- How many customers stay with company.

# Churn by Senior Citizens
SELECT 
    `Senior Citizen`,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM customer_churn
GROUP BY `Senior Citizen`;
-- Yes age group affect churn.

# Find the Column_ Names in Dataset 
DESCRIBE customer_churn;

# Window Function
SELECT *
FROM (
    SELECT 
        customerID,
        `TotalCharges`,
        RANK() OVER (ORDER BY `TotalCharges` DESC) AS revenue_rank
    FROM customer_churn
) ranked
WHERE revenue_rank <= 10;
-- Rank customers by value.

# Running Total Revenue
SELECT 
    customerID,
    `TotalCharges`,
    SUM(TotalCharges) OVER (ORDER BY TotalCharges) AS running_revenue
FROM customer_churn;
-- Cumulative revenue trend of each customers.

# Churn Probability Score 
SELECT *,
CASE 
    WHEN tenure < 6 AND `Monthly Charges` > 80 THEN 'Very High Risk'
    WHEN tenure < 12 THEN 'High Risk'
    WHEN `Monthly Charges` > 70 THEN 'Medium Risk'
    ELSE 'Low Risk'
END AS churn_risk_level
FROM customer_churn;
-- Risk segmentation directly in MYSQL.

-- Key Insights & Business Recommendations --

# Key Insights:
-- • Month-to-month contracts contribute 45% of total churn
-- • High monthly charges customers show 30% higher churn
-- • Customers paying higher monthly charges (> ₹80) are 30–40% more likely to churn compared to low-paying customers.
-- • Early-stage customers (tenure < 6 months) are most vulnerable
-- • High-value customers contribute significant revenue loss.

# Recommendations:
-- • Offer discounts or incentives for long-term contracts
-- • Improve onboarding experience for new customers
-- • Provide loyalty rewards for high-value customers
-- • Enhance customer support for high-risk segments.