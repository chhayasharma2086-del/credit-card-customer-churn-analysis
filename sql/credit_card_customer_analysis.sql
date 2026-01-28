#Create database Credit_Card_db;
USE credit_card_db;
SET SQL_SAFE_UPDATES = 0;
select * from clean_credit_card_customers limit 5;
# Overall Churn Rate
SELECT 
    Attrition_Flag,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM clean_credit_card_customers), 2) AS percentage
FROM clean_credit_card_customers
GROUP BY Attrition_Flag; 
#Insight:Shows 16% of customers that churned vs active.

#Churn by Gender
SELECT 
    Gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churn_count,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*), 2
    ) AS churn_rate
FROM clean_credit_card_customers
GROUP BY Gender;

#Churn by Age Group
SELECT 
    CASE 
        WHEN Customer_Age < 30 THEN 'Under 30'
        WHEN Customer_Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Customer_Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Customer_Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churn_count,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*), 2
    ) AS churn_rate
FROM clean_credit_card_customers
GROUP BY age_group
ORDER BY age_group;

#Churn by Income Category
SELECT 
    Income_Category,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churn_count,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*), 2
    ) AS churn_rate
FROM clean_credit_card_customers
GROUP BY Income_Category
ORDER BY churn_rate DESC;

#Churn by Credit Limit (Binned)
SELECT 
    CASE
        WHEN Credit_Limit < 2000 THEN 'Low (<2k)'
        WHEN Credit_Limit BETWEEN 2000 AND 5000 THEN 'Medium (2k-5k)'
        WHEN Credit_Limit BETWEEN 5000 AND 10000 THEN 'High (5k-10k)'
        ELSE 'Very High (>10k)'
    END AS credit_limit_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churn_count,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*), 2
    ) AS churn_rate
FROM clean_credit_card_customers
GROUP BY credit_limit_group
ORDER BY churn_rate DESC;

#Churn by Transaction Activity (Frequency)
SELECT 
    CASE
        WHEN Total_Trans_Ct < 40 THEN 'Low Activity (<40)'
        WHEN Total_Trans_Ct BETWEEN 40 AND 60 THEN 'Medium (40–60)'
        ELSE 'High (>60)'
    END AS activity_level,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churn_count,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*), 2
    ) AS churn_rate
FROM clean_credit_card_customers
GROUP BY activity_level
ORDER BY churn_rate DESC;

#High-Value vs Low-Value Customer Churn
SELECT
    CASE 
        WHEN Credit_Limit > (SELECT Avg(Credit_Limit) FROM clean_credit_card_customers)
         AND Total_Trans_Amt > (SELECT Avg(Total_Trans_Amt) FROM clean_credit_card_customers) 
         THEN 'High Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churn_count,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*), 2
    ) AS churn_rate
FROM clean_credit_card_customers
GROUP BY customer_segment
order by customer_segment;

#Predictive Features Correlated with Churn (Attrited Customer vs Existing Customer)
SELECT 
Attrition_Flag,
    AVG(Total_Trans_Ct) AS avg_trans_count,
    AVG(Total_Trans_Amt) AS avg_trans_amt,
    AVG(Total_Ct_Chng_Q4_Q1) AS avg_ct_change,
    AVG(Months_Inactive_12_mon) AS avg_inactive_months,
    AVG(Avg_Utilization_Ratio) AS avg_utilization
FROM clean_credit_card_customers
GROUP BY Attrition_Flag;

#High-Value vs Low-Value Customer Segmentation
SELECT
    CLIENTNUM,
    CASE 
        WHEN Total_Trans_Amt > 5000
         AND Total_Trans_Ct > 60 THEN 'High Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM clean_credit_card_customers;

#Engagement-Level Segmentation
ALTER TABLE clean_credit_card_customers ADD COLUMN Engagement_Level VARCHAR(25);
UPDATE clean_credit_card_customers
SET Engagement_Level =
    CASE
        WHEN Total_Trans_Ct < 40 THEN 'Low Engagement'
        WHEN Total_Trans_Ct BETWEEN 40 AND 60 THEN 'Medium Engagement'
        ELSE 'High Engagement'
    END
    WHERE CLIENTNUM IS NOT NULL;

#Income Category Segmentation
SELECT 
    CLIENTNUM,
    CASE
        WHEN Income_Category = 'Less than $40K' THEN 'Low Income'
        WHEN Income_Category IN ('$40K - $60K', '$60K - $80K') THEN 'Middle Income'
        WHEN Income_Category IN ('$80K - $120K', '$120K +') THEN 'High Income'
        ELSE 'Unknown'
    END AS income_group
FROM clean_credit_card_customers;

#Churn Segmentation (Active vs At-Risk)
SELECT
    CLIENTNUM,
    CASE
        WHEN Attrition_Flag = 'Attrited Customer' THEN 'Churned'
        ELSE 'Active'
    END AS churn_status
FROM clean_credit_card_customers;

#Customer Persona Segmentation 
ALTER TABLE clean_credit_card_customers ADD COLUMN Customer_Persona VARCHAR(30);
UPDATE clean_credit_card_customers
SET Customer_Persona =
    CASE
        WHEN Total_Trans_Amt > 5000 AND Attrition_Flag = 'Existing Customer'
            THEN 'Premium Loyal'
        WHEN Total_Trans_Amt > 5000 AND Attrition_Flag = 'Attrited Customer'
            THEN 'High-Value At-Risk'
        WHEN Total_Trans_Amt <= 5000 AND Attrition_Flag = 'Attrited Customer'
            THEN 'Low-Value At-Risk'
        ELSE 'Active Low-Value'
    END
    WHERE CLIENTNUM IS NOT NULL;
    
    
