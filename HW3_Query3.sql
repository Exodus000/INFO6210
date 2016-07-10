SELECT Max(T.TaxRate)as MaxRate,SP.CountryRegionCode
FROM Sales.SalesTaxRate T
JOIN Person.StateProvince SP
ON SP.StateProvinceID = T.StateProvinceID
GROUP BY SP.CountryRegionCode


