
SELECT SUM (SOH.TotalDue) AS Revenue,SP.Name
 FROM Sales.SalesOrderHeader SOH
 INNER JOIN Person.Address A
 ON SOH.ShipToAddressID =A.AddressID
 INNER JOIN Person.StateProvince SP
 ON A.StateProvinceID =SP.StateProvinceID
 WHERE YEAR(SOH.OrderDate) = 2006
GROUP BY  SP.Name
ORDER BY  Revenue DESC 

