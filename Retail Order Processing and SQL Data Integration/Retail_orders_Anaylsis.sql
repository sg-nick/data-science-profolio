use retail_orders;
select * from orders;

# finds the top 10 products by total sales by summing the sale_price for each product_id, 
# grouping the results by product_id, and then ordering the products by their total sales in descending order
select product_id, SUM(sale_price) AS sales
from orders
group by product_id
order by sales desc
limit 10;




#identifying top 5 highest-selling products in each region by first summing the sales for each product within each region,
# then using a row numbering function to rank the products by sales within each region
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM orders
    GROUP BY region, product_id
)
SELECT region, product_id, sales
FROM (
    SELECT region, product_id, sales,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte
) subquery
WHERE rn <= 5;



# calculates the total sales for each month in 2022 and 2023,
# then computes and rounds the percentage growth from 2022 to 2023 for each month, ordering the results by month
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,
    ROUND(SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END), 2) AS sales_2022,
    ROUND(SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END), 2) AS sales_2023,
    CASE 
        WHEN SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) > 0 
        THEN ROUND(
            ((SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) - SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END)) 
            / SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END)) * 100, 
            2
        )
        ELSE NULL
    END AS growth_percentage
FROM cte 
GROUP BY order_month
ORDER BY order_month;

#identifies the highest monthly sales for each product category by aggregating sales data by category and month,
# then using a row numbering function to rank the months by sales within each category,
# and selecting the month with the highest sales for each category.

WITH cte AS (
    SELECT 
        category,
        FORMAT(order_date, 'yyyyMM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM orders
    GROUP BY category, FORMAT(order_date, 'yyyyMM')
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) a
WHERE rn = 1;
