SELECT TOP 1P.Name,(OrderQty * UnitPrice) AS TOTAL, PO.DueDate
FROM Production.Product P
JOIN Purchasing.PurchaseOrderDetail PO
ON P.ProductID = PO.ProductID
WHERE PO.DueDate BETWEEN '2005/05/01' AND '2005/05/31'
ORDER BY TOTAL desc