CREATE FUNCTION fn_SetIfPlatinum (@OrderHeaderID INT)
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
