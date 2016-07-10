SELECT c.name, COUNT(*) AS"TOATL ISSUED"
FROM Production.Product P
JOIN Production.WorkOrder W
ON W.ProductID = P.ProductID
JOIN Production.ProductSubcategory S
ON S.ProductSubcategoryID = P.ProductSubcategoryID
JOIN Production.ProductCategory C
ON C.ProductCategoryID = S.ProductCategoryID
WHERE w.StartDate BETWEEN '2004/03/08' AND '2010/05/02'
GROUP BY c.name
