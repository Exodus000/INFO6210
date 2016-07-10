/*Write a query that returns ranking of commission percentages by sales person. 
Notes:  
A rank of ¡°1¡± should relate to the sales person with the greatest commission percentage 
If commission percentages are equal among sales people, rank by Bonus in descending order (Adventureworks2012:	Sales ERD)*/


SELECT P.BusinessEntityID,P.FirstName,P.LastName,SP.CommissionPct,SP.Bonus,
Rank = DENSE_RANK()OVER (ORDER BY SP.CommissionPct DESC, SP.Bonus desc)
FROM Person.Person P
JOIN Sales.SalesPerson SP
ON SP.BusinessEntityID = P.BusinessEntityID
