/*2. Based on sales data from 2005, write a query that calculates the number of sales orders
 within each of the following revenue ranges:
a) $0- 5000
b) > $10000
*/


(SELECT '0-5000' AS Revenue, count(SOH.SalesOrderID) AS 'Number of sales orders'
FROM Sales.SalesOrderHeader  SOH
JOIN Sales.SalesOrderDetail SOD
ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE SOD.OrderQty * SOD.UnitPrice <= 5000)
union(
SELECT '>10000' AS Revenue, count(SOH.SalesOrderID) AS 'Number of sales orders'
FROM Sales.SalesOrderHeader  SOH
JOIN Sales.SalesOrderDetail SOD
ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE SOD.OrderQty * SOD.UnitPrice >10000
)
 
