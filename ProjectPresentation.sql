--Computed column
--1.Find the lasted maintenance record of each facility
Create FUNCTION fnLatestMaintDate(@FacilityID int)
returns datetime
AS
Begin
Declare @latestMaintDate datetime
Set @latestMaintDate=(select max(dbo.Facility_Maintenance.FacilityMaintDate) from dbo.Facility_Maintenance 
where dbo.Facility_Maintenance.facilityID=@FacilityID)
return @latestMaintDate
End 

alter table facility add LatestMaintDate as (dbo.fnLatestMaintDate(facility.FacilityID))


--2.Find the total price of each orderDetail list
CREATE FUNCTION fnTotalPrice(@OrderDetailID int)
Returns smallMoney
AS
Begin
Declare @TotalPrice SmallMoney
Declare @FoodID int
Declare @Price SmallMoney
SET @FoodID=(select dbo.OrderDetail.FoodID from dbo.OrderDetail where dbo.OrderDetail.OrderDetailID=@OrderDetailID )
SET @Price=(select dbo.Food.Price from dbo.Food where dbo.Food.FoodID=@FoodID)
SET @TotalPrice=(select (dbo.OrderDetail.ProductQty*@Price) from dbo.OrderDetail where dbo.OrderDetail.OrderDetailID=@OrderDetailID)
Return @TotalPrice
End

Alter Table dbo.OrderDetail add TotalPrice as (dbo.fnTotalPrice(OrderDetail.OrderDetailID) )

--3.Find the subTotal of each OrderHeader list
ALter FUNCTION fnSubTotal(@OrderHeaderID int)
Returns SmallMoney
AS
Begin
Declare @SubTotal SmallMoney
SET @SubTotal=(select sum(OrderDetail.TotalPrice)  from OrderDetail 
join OrderHeader on OrderDetail.OrderHeaderID=OrderHeader.OrderHeaderID 
where OrderHeader.OrderHeaderID = @OrderHeaderID )
Return @SubTotal
End
Alter Table dbo.OrderHeader add SubTotal as(dbo.fnSubTotal(OrderHeader.OrderHeaderID));

--4/*Computed Column Count Delivery Fee */
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

--5: Calculate Tax per OrderHeader
CREATE FUNCTION fn_calcTax(@OrderHeaderID INT)
RETURNS SMALLMONEY
AS
BEGIN
DECLARE @RES SMALLMONEY =
(SELECT SI.TaxRate * OH.SubTotal/100 AS Tax FROM dbo.STATEINFO SI
INNER JOIN dbo.STORE S
ON SI.StateID = S.StateID
INNER JOIN dbo.ORDERHEADER OH
ON S.StoreID = OH.StoreID
WHERE OH.OrderHeaderID = @OrderHeaderID)
RETURN @RES
END


ALTER TABLE dbo.ORDERHEADER
ADD Tax AS (dbo.fn_calcTax(OrderHeaderID))

ALTER TABLE dbo.ORDERHEADER
DROP COLUMN Tax

--6.Calculate TotalDue per OrderHeader
CREATE FUNCTION fn_calcTotalDue(@OrderHeaderID INT)
RETURNS SMALLMONEY
AS
BEGIN
DECLARE @RES SMALLMONEY =
(SELECT (SubTotal + DeliveryFee + Tax) AS TotalDue FROM dbo.ORDERHEADER
WHERE OrderHeaderID = @OrderHeaderID)
RETURN @RES
END

ALTER TABLE dbo.ORDERHEADER
ADD TotalDue AS (dbo.fn_calcTotalDue(OrderHeaderID))

ALTER TABLE dbo.ORDERHEADER
DROP COLUMN TotalDue


--StoreProcedure

--1./*Add a Store*/
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

--2./*Add an Employee*/
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

--3.Customer make a Reservation(Status: Tentative)
CREATE PROCEDURE uspNEWReservation
@StartTime DATETIME,
@Size INT,
@FirstName VARCHAR(30),
@LastName VARCHAR(30)
AS
DECLARE @CustomerID INT
SET @CustomerID = (SELECT CustomerID FROM dbo.CUSTOMER 
WHERE FirstName = @FirstName AND LastName = @LastName)
INSERT INTO dbo.RESERVATION (StartTime, Size, CustomerID)
VALUES (@StartTime, @Size, @CustomerID)
DECLARE @ReservationID INT
SET @ReservationID = (SELECT MAX(ReservationID) FROM dbo.RESERVATION)
INSERT INTO dbo.RESERVATION_STATUS (ReservationID, StatusID, ResStatusDateTime)
VALUES (@ReservationID, 2, @StartTime)

EXEC uspNEWReservation
@StartTime = '2015-12-12',
@Size = 5,
@FirstName = 'Grace',
@LastName = 'Alexander'

--4.Confirm a Reservation, meaning the customer has shown up(Status: Confirmed)
CREATE PROCEDURE uspConfirmReservation
@EndTime DATETIME,
@ReservationID INT
AS
DECLARE @Count INT
DECLARE @StatusID INT
SET @COUNT = (SELECT COUNT(StatusID) FROM dbo.RESERVATION_STATUS 
WHERE ReservationID = @ReservationID)
IF @Count = 1
BEGIN
SET @StatusID = (SELECT StatusID FROM dbo.RESERVATION_STATUS 
WHERE ReservationID = @ReservationID)
IF @StatusID = 2
BEGIN
UPDATE dbo.RESERVATION SET EndTime = @EndTime WHERE ReservationID = @ReservationID
INSERT INTO dbo.RESERVATION_STATUS (ReservationID, StatusID, ResStatusDateTime)
VALUES (@ReservationID, 1, @EndTime)
END
END

EXEC uspConfirmReservation
@EndTime = '2015-12-12',
@ReservationID = 1391

--5. Cancel a Reservation(Status: Cancelled)
CREATE PROCEDURE uspCancelReservation
@ReservationID INT,
@EndTime DATETIME
AS 
DECLARE @Count INT
DECLARE @StatusID INT
SET @COUNT = (SELECT COUNT(StatusID) FROM dbo.RESERVATION_STATUS 
WHERE ReservationID = @ReservationID)
IF @Count = 1
BEGIN
SET @StatusID = (SELECT StatusID FROM dbo.RESERVATION_STATUS 
WHERE ReservationID = @ReservationID)
IF @StatusID = 2
BEGIN
UPDATE dbo.RESERVATION SET EndTime = @EndTime WHERE ReservationID = @ReservationID
INSERT INTO dbo.RESERVATION_STATUS (ReservationID, StatusID, ResStatusDateTime)
VALUES (@ReservationID, 4, @EndTime)
END
END

EXEC uspConfirmReservation
@EndTime = '2015-12-12',
@ReservationID = 1391

--6.Facility Maintainance
CREATE PROCEDURE uspFacilityMaintainance
@FacilityName VARCHAR(100),
@StoreName 
@MaintainanceName VARCHAR(100),
@FacilityMaintDate DATETIME
AS
DECLARE @FacilityID INT
DECLARE @MaintainanceID INT
SET @FacilityID = (SELECT FacilityID FROM dbo.FACILITY
WHERE FacilityName = @FacilityName)
SET @MaintainanceID = (SELECT MaintainanceID FROM dbo.MAINTAINANCE
WHERE MaintainanceName = @MaintainanceName)
INSERT INTO dbo.FACILITY_MAINTENANCE (FacilityID, MaintenanceID, FacilityMaintDate)
VALUES (@FacilityID, @MaintainanceID, @FacilityMaintDate)

SELECT * FROM dbo.Facility_Maintenance
EXEC uspFacilityMaintainance
@FacilityName = 'microwave oven',
@MaintainanceName = 'YearsRegular',
@FacilityMaintDate = '2015-12-13'

--7. add a new transaction

Alter PROCEDURE uspNewTransaction(@StoreName varchar(100),@FoodName varchar(50),
@Qty int,@CustFistName varchar(30),@CustLastName varchar(30),@Emp_FirstName varchar(30),
@Emp_LastName varchar(30),@Emp_PositionName varchar(50))
AS
Declare @StoreID int
Declare @FoodID int
Declare @CustomerID int 
Declare @EmpPositionID int
Declare @OrderDateTime datetime
SET @StoreID=(Select Store.StoreID from Store where Store.Name=@StoreName)
SET @FoodID=(select Food.FoodID from Food where Food.FoodName=@FoodName)
SET @CustomerID=(select Customer.CustomerID from Customer where Customer.FirstName=@CustFistName and Customer.LastName=@CustLastName)
SET @EmpPositionID=(select Employee_Position.EmpPositionID from Employee_Position 
					join EMPLOYEE on Employee_Position.EmpID=Employee.EmpID
					join Position on Position.PositionID=Employee_Position.PositionID
					where Employee.FirstName=@Emp_FirstName 
					and Employee.LastName=@Emp_LastName 
					and Position.PositionName=@Emp_PositionName)
SET  @OrderDateTime=(select(getdate()))

Insert Into OrderHeader (StoreID,OrderDateTime,CustomerID,EmpPositionID)
values(@StoreID,@OrderDateTime, @CustomerID,@EmpPositionID)

DECLARE @OrderHeaderID int
SET @OrderHeaderID =(select max(OrderHeader.OrderHeaderID) from OrderHeader)
Insert into OrderDetail (ProductQty,OrderHeaderID,FoodID)
values(@Qty,@OrderHeaderID,@FoodID);
DECLARE @GiftCardID int
SET @GiftCardID=(select GiftCard.GiftCardID from GiftCard 
where GiftCard.CustomerID=@CustomerID 
and GiftCard.Balence>(select OrderHeader.TotalDue from OrderHeader where OrderHeader.OrderHeaderID=@OrderHeaderID)
and GiftCard.ExpirationDate>@OrderDateTime)

Insert Into Payment (OrderHeaderID,GiftCardID)
Values(@OrderHeaderID,@GiftCardID)

if @GiftCardID is not null
Begin
Update GiftCard 
set GiftCard.Balence=(GiftCard.Balence-(select OrderHeader.TotalDue from OrderHeader where OrderHeader.OrderHeaderID=@OrderHeaderID))
where GiftCard.GIftCardID=@GiftCardID
End


Exec uspNewTransaction 'Kittery','Pecan Tart',2,'Ana','Alexander','Cara','Zhang','Barista'


--Check
--1. BY Ying
CREATE FUNCTION fn_ckReservation(@CustomerID INT)
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS (SELECT * FROM dbo.ORDERHEADER
WHERE CustomerID = @CustomerID)
SET @RET = 1
RETURN @RET
END

DROP FUNCTION dbo.fn_ckReservation

ALTER TABLE RESERVATION
ADD CONSTRAINT CK_RESERVATION
CHECK (dbo.fn_ckReservation(CustomerID) = 1)

ALTER TABLE dbo.RESERVATION
DROP CONSTRAINT CK_RESERVATIONS


SELECT * FROM dbo.ORDERHEADER
WHERE CustomerID = 818

INSERT INTO dbo.RESERVATION(STARTTIME, SIZE, CUSTOMERID)
VALUES ('2014-05-24 06:52:25.000', 3, 818)

--2.
ALTER TABLE dbo.RESERVATION
ADD CONSTRAINT CK_SIZE
CHECK (Size > 0 AND Size <= 10)

SELECT * FROM RESERVATION WHERE CustomerID = 817

DELETE FROM RESERVATION WHERE ReservationID = 1402

--Check 3 BY KK

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


--check 4 
Create FUNCTION fnMaintDates(@FacilityID int)
Returns int
AS 
Begin
Declare @dates int
SET @dates=(datediff(day,(select max(Facility_Maintenance.FacilityMaintDate) 
from Facility_Maintenance where Facility_Maintenance.FacilityID=@FacilityID and Facility_Maintenance.MaintenanceID<>3 ),getdate()))
Return @dates
End 

Alter Table Facility_Maintenance
add constraint checkMaintDates
check(dbo.fnMaintDates(Facility_Maintenance.FacilityID)>60)

Insert into  Facility_Maintenance(FacilityID,MaintenanceID,FacilityMaintDate)
values(1,2,getdate())