/*4) You are asked to write a query which returns the greatest number of vacation hours of 
the employees. Please generate an output that contains the following information:   
a) Last four digits of National ID Number
b) FirstName
c) LastName
d) JobTitle
*/

select right(E.NationalIDNumber,4)as'Last four digits of National ID Number',
P.FirstName,P.LastName,E.JobTitle
from HumanResources.Employee E
join Person.person P on E.BusinessEntityID = P.BusinessEntityID
where E.VacationHours = (  select VacationHours = max(VacationHours) from HumanResources.Employee )
order by E.VacationHours