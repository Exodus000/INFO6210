SELECT  C.Name ,avg(rating) AS Rating
FROM Production.ProductReview R
JOIN Production.Product P
ON P.ProductID  = R.ProductID
JOIN Production.ProductSubcategory S
ON S.ProductSubcategoryID = P.ProductSubcategoryID
JOIN Production.ProductCategory C
ON C.ProductCategoryID = S.ProductCategoryID
WHERE P.SellStartDate BETWEEN '2004/01/01' AND '2010/12/31'
AND C.Name = 'Bikes'
GROUP BY c.Name

