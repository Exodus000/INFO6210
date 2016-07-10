SELECT top 1 JobTitle, d.Name AS 'Department', p.HireDate, FirstName +' '+ LastName AS Name
FROM HumanResources.Employee P
JOIN HumanResources.EmployeeDepartmentHistory E
ON P.BusinessEntityID = E.BusinessEntityID
JOIN HumanResources.Department D
ON D.DepartmentID = E.DepartmentID 
JOIN person.Person PP 
ON p.BusinessEntityID = pp.BusinessEntityID
WHERE d.Name = 'Engineering' OR d.Name = 'Finance'
ORDER BY P.HireDate
