SELECT E.BusinessEntityID,P.FirstName,P.LastName,EPH.Rate * 50 AS HolidayBonuses
FROM HumanResources.Employee E
JOIN HumanResources.EmployeePayHistory EPH
ON E.BusinessEntityID = EPH.BusinessEntityID
INNER JOIN Person.Person P
ON P.BusinessEntityID = E.BusinessEntityID
WHERE E.SalariedFlag = 1
ORDER BY E.BusinessEntityID
