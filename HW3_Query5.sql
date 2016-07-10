/*An administrator from Human Resources asks you for a list of employees 
who are currently in the Marketing department and were hired prior to 2002 or later than 2004.
 (Adventureworks2012:	Human Resources ERD)*/

SELECT P.FirstName,P.LastName, D.name,E.HireDate,EDH.EndDate
FROM Person.Person P
JOIN HumanResources.Employee E
ON P.BusinessEntityID = E.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory EDH
ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN HumanResources.Department D
ON EDH.DepartmentID =D.DepartmentID
WHERE D.Name = 'Marketing'
AND ( YEAR(E.HireDate) <2002 OR YEAR(E.HireDate) > 2004)
AND EDH.EndDate is NULL
ORDER BY E.HireDate

