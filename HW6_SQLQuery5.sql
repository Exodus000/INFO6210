/*5) AdventureWorks will feature one product for the cover of its print catalog. 
Help select a list of products for consideration. Your list should contain products 
which meet all of the following conditions: 
a) Finished goods 
b) List price at least $ 1,500 
*/


select PM.name as Name,PPH.ListPrice
from production.ProductListPriceHistory PPH
JOIN Production.Product P on PPH.productID = P.productID
JOIN production.ProductModel PM on PM.ProductModelID =P.ProductModelID
where PPH.ListPrice >= 1500 and p.FinishedGoodsFlag = 1
group by PM.name,PPH.ListPrice

