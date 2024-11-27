-- @conn ETL
SELECT count(*) from customers;
SELECT count(*) from customers where "State" = 'TX';
SELECT "State", "City", COUNT("CustomerID") AS CustomerCount
FROM customers
GROUP BY "State", "City"
ORDER BY COUNT("CustomerID") DESC;