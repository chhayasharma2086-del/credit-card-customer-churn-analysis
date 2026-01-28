USE credit_card_db;

#Verify the table
select * from clean_credit_card_customers limit 5;

#Summary of churn
UPDATE clean_credit_card_customers
SET Engagement_Level =
    CASE
        WHEN Total_Trans_Ct < 40 THEN 'Low Engagement'
        WHEN Total_Trans_Ct BETWEEN 40 AND 60 THEN 'Medium Engagement'
        ELSE 'High Engagement'
    END;

#Summary of High-Value vs Low-Value Customers
SELECT High_Value_Customer, COUNT(*) 
FROM clean_credit_card_customers
GROUP BY High_Value_Customer;

#Churn Rate by Segment
SELECT High_Value_Customer,
       ROUND(AVG(Churn) * 100, 2) AS churn_rate_percent
FROM clean_credit_card_customers
GROUP BY High_Value_Customer;

#Demographic summary
SELECT Gender, COUNT(*) FROM clean_credit_card_customers GROUP BY Gender;

#Behavior by segment
SELECT 
    High_Value_Customer,
    ROUND(AVG(Total_Trans_Amt), 2) AS avg_amt,
    ROUND(AVG(Total_Trans_Ct), 2) AS avg_ct,
    ROUND(AVG(Credit_Limit), 2) AS avg_limit,
    ROUND(AVG(Avg_Utilization_Ratio), 3) AS avg_util
FROM clean_credit_card_customers
GROUP BY High_Value_Customer;

#Base Tbale for Tableau
SELECT *
FROM clean_credit_card_customers;

#Churn-Focused View
SELECT 
   CLIENTNUM,
    Churn,
    Customer_Age,
    Gender,
    Marital_Status,
    Income_Category,
    Education_Level,
    Total_Trans_Amt,
    Total_Trans_Ct,
    Credit_Limit,
    Avg_Utilization_Ratio
FROM clean_credit_card_customers;

#Segmentation View
SELECT
     CLIENTNUM,
    High_Value_Customer,
    Total_Trans_Amt,
    Total_Trans_Ct,
    Credit_Limit,
    Avg_Utilization_Ratio,
    Gender,
    Customer_Age,
    Income_Category,
    Education_Level
FROM clean_credit_card_customers;

#Behavioral / Spend View
SELECT
    CLIENTNUM,
    Total_Trans_Amt,
    Total_Trans_Ct,
    Total_Revolving_Bal,
    Credit_Limit,
    Avg_Utilization_Ratio,
    Months_on_book,
    Dependent_count,
    High_Value_Customer,
    Churn
FROM clean_credit_card_customers;


