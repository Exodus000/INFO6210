SELECT count(W.WorkOrderID) AS WorkOrders,P.ProductID
FROM Production.WorkOrder W
JOIN Production.Product P
ON P.ProductID = W.ProductID
Group by P.ProductID,P.ProductID

Order by WorkOrders DESC

