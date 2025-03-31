-- Prompt --
-- You're working for a company that sells motorcycle parts, and they've asked for some help in analyzing their sales data!

-- They operate three warehouses in the area, selling both retail and wholesale. They offer a variety of parts and accept credit cards, cash, and bank transfer as payment methods. However, each payment type incurs a different fee.

-- The board of directors wants to gain a better understanding of wholesale revenue by product line, and how this varies month-to-month and across warehouses. You have been tasked with calculating net revenue for each product line and grouping results by month and warehouse. The results should be filtered so that only "Wholesale" orders are included.

-------------------------------------------------------------------------------------------------------------------------------

-- Find out how much Wholesale net revenue each product_line generated per month per warehouse in the dataset. 

SELECT product_line, 
	CASE WHEN EXTRACT('month' from date) = 1 THEN 'January'
		WHEN EXTRACT('month' from date) = 2 THEN 'February'
		WHEN EXTRACT('month' from date) = 3 THEN 'March'
		WHEN EXTRACT('month' from date) = 4 THEN 'April'
		WHEN EXTRACT('month' from date) = 5 THEN 'May'
		WHEN EXTRACT('month' from date) = 6 THEN 'June'
		WHEN EXTRACT('month' from date) = 7 THEN 'July'
		WHEN EXTRACT('month' from date) = 8 THEN 'August'
		WHEN EXTRACT('month' from date) = 9 THEN 'September'
		WHEN EXTRACT('month' from date) = 10 THEN 'October'
		WHEN EXTRACT('month' from date) = 11 THEN 'November'
		ELSE 'December' END AS month, 
	warehouse, 
	SUM(total-payment_fee) AS net_revenue
FROM sales
WHERE client_type = 'Wholesale'
GROUP BY product_line, month, warehouse
ORDER BY product_line, month;
