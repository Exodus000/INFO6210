/*Write a query that provides address data about stores with main offices located in Toronto. 
(Adventureworks2012: Person ERD)*/


SELECT A.City,A.PostalCode, A.AddressLine1,A.AddressLine2,AT.Name as AddressType
FROM Person.Address A
JOIN  Person.BusinessEntityAddress BEA
ON A.AddressID = BEA.AddressID
JOIN Person.AddressType AT
ON BEA.AddressTypeID = AT.AddressTypeID
WHERE A.City = 'Toronto'
AND AT.AddressTypeID = '3'
ORDER BY A.AddressLine2 DESC

