
/*Computed Column Count Delivery Fee */
CREATE FUNCTION fn_CountDeliveryFee (@OrderHeaderID INT)
RETURNS INT
AS
BEGIN
DECLARE @Ret INT 
DECLARE @SubTotal Smallmoney

SET  @SubTotal =(SELECT OH.SubTotal from dbo.ORDERHEADER OH 

WHERE OH.OrderHeaderID = @OrderHeaderID)

if  @SubTotal > 20 set @Ret = 0

else if (@SubTotal <20 and @SubTotal>=10) set @Ret = 2

else if (@SubTotal<10 and @SubTotal>0)    set @Ret = 5

RETURN @Ret

END

ALTER TABLE dbo.OrderHeader
ADD DeliveryFee AS(dbo.fn_CountDeliveryFee(OrderHeaderID))



ALTER TABLE dbo.OrderHeader 
DROP COLUMN DeliveryFee


/*Add a Store*/
CREATE PROCEDURE uspAddStore
@StateName varchar(30),
@StoreType  varchar(30),
@Name varchar(100),
@Location varchar(30),
@city varchar(30)

AS

DECLARE @StateID INT
DECLARE @StoreTypeID INT


SET @StateID = (SELECT StateID FROM StateINFO SI WHERE SI.Name = @StateName)
SET @StoreTypeID= (SELECT StoreTypeID FROM Store_Type ST WHERE ST.StoreTypeName = @StoreType )

INSERT INTO dbo.Store([StateID],[StoreTypeID],[Name],[Location],[city])
VALUES (@StateID,@StoreTypeID,@name,@location,@city)


USE store_reddragon;
GO
EXEC dbo.uspAddStore @StateName = California, @StoreType = foodcart, @name = newStore,
@Location = newLocation, @city = newCity;


DROP PROCEDURE uspAddStore;
GO

/*Add an Employee*/
CREATE PROCEDURE uspAddEmployee

@FirstName varchar(30),
@LastName varchar(30),
@Position  varchar(50),
@Salary int,
@EndDate  datetime

AS

DECLARE @EmpID int
DECLARE @PositionID INT
DECLARE @BeginDate datetime

SET @EmpID = (SELECT EmpID FROM employee E WHERE E.FirstName = @FirstName and E.LastName = @Lastname)
SET @PositionID= (SELECT PositionID FROM Position P WHERE P.PositionName = @Position )
SET @BeginDate = GETDATE()

INSERT INTO dbo.employee_position([EmpID],[PositionID],[Salary],[BeginDate],[EndDate])
VALUES (@EmpID,@PositionID,@Salary,@BeginDate,@EndDate)

USE store_reddragon;
GO
EXEC dbo.uspAddEmployee @FirstName = Lucas, @LastName = Allen, @Position = Bartender,
@Salary = 8900,@EndDate = null ;

DROP PROCEDURE uspAddEmployee;
GO

/*Check */

CREATE FUNCTION fn_ckManager (@EmpID INT)
RETURNS INT
AS
BEGIN
DECLARE @Ret INT
declare @res int

set @res = (SELECT sum( OH.SubTotal) from ORDERHEADER OH
join EMPLOYEE_POSITION EP on EP.EmpPositionID =OH.EmpPositionID 
 where Ep.EmpID = @EmpID  )

IF 

@res> 900

SEt @ret = 1
RETURN @Ret 

END

ALTER TABLE employee_position
add constraint ck_Manager
Check (dbo.fn_ckManager (EmpID) = 1)


ALTER TABLE employee_position DROP CONSTRAINT ck_Manager;

go

drop function  fn_ckManager

INSERT INTO [store_reddragon].[dbo].[employee_position]
           ([EmpID]
           ,[PositionID],[salary],[BeginDate])
     VALUES
           (99,5,5000,getdate())

		   /*test*/

use Store_RedDragon
SELECT 
  e.EmpID,E.FirstName,E.LastName,p.positionID,P.positionName
FROM Employee E
JOIN Employee_Position EP
  ON E.EmpID = EP.EmpID
JOIN Position P
  ON P.PositionID = EP.PositionID
WHERE YEAR(GETDATE()) - YEAR(E.DateOfBirth) < 35
AND P.PositionName = 'Manager'
order by p.positionID


SELECT sum( OH.SubTotal) as Total,EP.EmpID from ORDERHEADER OH 
join EMPLOYEE_POSITION EP on EP.EmpPositionID =OH.EmpPositionID 

group by EP.EmpID
order by total

/*Check 2 */

CREATE FUNCTION fn_test (@EmpID INT)
RETURNS INT
AS
BEGIN
DECLARE @Ret INT = 0

if exists (
SELECT E.DateOfBirth from EMPLOYEE E
 where E.EmpID = @EmpID and  YEAR(GETDATE()) - YEAR(E.DateOfBirth) < 70
 
) 

SEt @Ret = 1
RETURN @Ret 

END

ALTER TABLE employee_position
add constraint ck_test
Check (dbo.fn_test (EmpID) = 1)


ALTER TABLE employee_position DROP CONSTRAINT ck_test;

go

drop function  fn_test


INSERT INTO [store_reddragon].[dbo].[employee_position]
           ([EmpID]
           ,[PositionID],[salary],[BeginDate])
     VALUES
           (107,5,5000,getdate())


/*test 2*/
SELECT  YEAR(GETDATE()) - YEAR(E.DateOfBirth) as age,EP.EmpID from ORDERHEADER OH 
join EMPLOYEE_POSITION EP on EP.EmpPositionID =OH.EmpPositionID 
join EMPLOYEE E on E.EmpID =EP.EmpID

group by E.DateOfBirth,EP.EmpID
order by age
