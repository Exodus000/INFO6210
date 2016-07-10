SELECT TOP 3FirstName,LastName, BirthDate, CR.Name AS CountryRegion
FROM Person.Person P
JOIN HumanResources.Employee E 
ON E.BusinessEntityID = P.BusinessEntityID
JOIN Person.BusinessEntity B
ON B.BusinessEntityID =P.BusinessEntityID
JOIN Person.BusinessEntityAddress A 
ON A.BusinessEntityID = B.BusinessEntityID
JOIN Person.Address PA
ON PA.AddressID = A.AddressID
JOIN Person.StateProvince SP
ON SP.StateProvinceID = PA.StateProvinceID
JOIN Person.CountryRegion CR
ON CR.CountryRegionCode =SP.CountryRegionCode
WHERE CR.Name = 'United States'
ORDER BY E.BirthDate

