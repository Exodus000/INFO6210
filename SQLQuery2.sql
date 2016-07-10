SELECT C.Name, COUNT(*) AS "Total number" ,sr.Name AS ScrapReason
FROM Production.Product p
JOIN Production.WorkOrder W
ON W.ProductID = P.ProductID
JOIN Production.ScrapReason SR
ON W.ScrapReasonID = SR.ScrapReasonID
JOIN Production.ProductSubcategory S
ON S.ProductSubcategoryID = P.ProductSubcategoryID
JOIN Production.ProductCategory C
ON C.ProductCategoryID = S.ProductCategoryID
WHERE sr.name ='Handling damage'
AND C.name = 'bikes'
GROUP BY c.name, sr.Name
