/*3. Management will review the current distribution of labor by shift within the Production
 department. 
Write a query to create a report that includes the following: 
a) Department name (Production) 
b) Shift name 
c) Number of employees
*/

select 'Production' as 'Department name' ,S.Name,count (E.BusinessEntityID ) as'Number of employees'
From HumanResources.Shift S
JOIN HumanResources.EmployeeDepartmentHistory EDH on S.ShiftID = EDH.ShiftID
JOIN HumanResources.Employee E on E.BusinessEntityID = EDH.BusinessEntityID
Group by S.ShiftID,S.Name
