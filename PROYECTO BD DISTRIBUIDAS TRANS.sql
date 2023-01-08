use AdventureWorks2019

go
create procedure consultaA as

	select soh.TerritoryID, sum(t.LineTotal) as Total_Ventas
	from Sales.SalesOrderHeader soh
	inner join
	(select salesorderid, productid, orderqty, linetotal
	from Sales.SalesOrderDetail sod
	where ProductID in (
		select ProductID
		from Production.Product
		where ProductSubcategoryID in (
			select ProductSubcategoryID
			from Production.ProductSubcategory
			where ProductCategoryID in(
				select ProductCategoryID
				from Production.ProductCategory	
				where ProductCategoryID = 1
			)
		)
	)) as T
	on soh.SalesOrderID = t.SalesOrderID
	group by soh.TerritoryID
	order by soh.TerritoryID

/*Transaction*/
use AdventureWorks2019

begin transaction
select b.CardType, b.CardNumber, a.ExpMonth, a.ExpYear
from [Linkedserver1].CreditCard.dbo.SalesCreditCard
inner join Person a on b.BusinessEntity=a.Num order by a.Num;
commit

rollback

select*from Sales.CreditCard
select*from Sales.PersonCreditCard

begin transaction
update BusinessEntityID
select Num = CardNumber
from [Linkedserver1].AdventureWorks2019.dbo.Sales.CreditCard
inner join Sales.PersonCreditCard
on c.Num = CreditCardID;

select*from Sales.CreditCard
select*from Sales.PersonCreditCard

rollback

go
alter procedure actualizar_correo 
	@correo_actual nvarchar(50),
	@correo_nuevo nvarchar(50)
as 
if exists (select EmailAddressID as a from Person.EmailAddress where EmailAddress = @correo_actual)
begin 
	update Person.EmailAddress set EmailAddress = @correo_nuevo where EmailAddressID = a
end

else
begin
	print 'No existe un correo registrado'
end

exec actualizar_correo 'ken0@adventureworks.com', 'ken1@adventureworks.com'

select * from Person.EmailAddress

/*TRANSACCIONES DISTRIBUIDAS*/
use AdventureWorks2019

select @@error

select ListPrice from Production.Product
where ProductID = 720

select * from sales.SalesOrderDetail 
where salesorderid = 43659

begin transaction transaccionA
  declare @producto int
  declare @precio money

  set @producto = 720
  set @precio = 15.7

  if exists(select productid
          from production.product
		  where productid = @producto)
    begin
       update Production.product
       set listprice = @precio
       where productid = @producto

	   -- se pone a dormir el proceso A
	   waitfor delay '00:00:10' 

	   rollback tran transaccionA
	end 
  else 
    begin
      print 'Producto no existe'
	end

/*PROCESO B*/
use AdventureWorks2019

begin tran 

set transaction isolation level read uncommitted

declare @orden int
declare @producto int
declare @cantidad int
declare @precio money

set @orden = 43659
set @producto = 720
set @cantidad = 2

select @precio = listprice
from Production.Product
where ProductID = @producto

print @precio

waitfor delay '00:00:15'

if exists (select salesorderid
           from sales.SalesOrderDetail
		   where salesorderid = @orden)
     if exists(select productid
               from production.product
		       where productid = @producto)
        INSERT INTO [Sales].[SalesOrderDetail]
           ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate])
		VALUES
           (@orden
           ,N'4911-403C-98'
           ,@cantidad
           ,@producto
           ,1
           ,@precio*1.1
           ,0.00
           ,newid()
           ,getdate())
     else
	   print 'producto no existe'
   else
     print 'orden no existe'
commit

rollback