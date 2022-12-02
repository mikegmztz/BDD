--CÓDIGO A EJECUTARSE EN LA BASE COMPLETA DE ADVENTUREWORKS
-- Para el fragmento 1 (Fragmento1AW)
--Servidores vinculados
 --Hacia el primer fragmento
 EXEC sp_addlinkedserver
   @server=N'ConnectionInstancia1AdventureWorks',
   @srvproduct=N'SQLServer',
   @provider=N'SQLOLEDB', -- Microsoft OLE DB Provider for SQL Server
   @datasrc=N'(Dirección)\(Nombre-Instancia)';

EXEC sp_addlinkedsrvlogin
    @rmtsrvname = N'ConnectionInstancia1AdventureWorks',
    @useself = N'true', -- Se conecta con al servidor remoto con las credenciales actuales del servidor local
    @locallogin = NULL; -- Se establece en NULL para que se vean afectados todos los inicios de sesión locales

EXEC sp_serveroption
    @server = 'ConnectionInstancia1AdventureWorks',
    @optname = 'Collation Compatible',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionInstancia1AdventureWorks',
    @optname = 'Data Access',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionInstancia1AdventureWorks',
    @optname = 'RPC',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionInstancia1AdventureWorks',
    @optname = 'RPC out',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionInstancia1AdventureWorks',
    @optname = 'Use Remote Collation',
    @optvalue = 'true';

EXEC sp_serveroption -- PENDIENTE
    @server = 'ConnectionInstancia1AdventureWorks',
    @optname = 'remote proc transaction promotion',
    -- Enable Promotion of Distributed Transactions for RPC
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionInstancia1AdventureWorks',
    @optname = 'Dist', --Distributor
    @optvalue = 'false';


EXEC sp_serveroption
    @server = 'ConnectionInstancia1AdventureWorks',
    @optname = 'Pub', --publisher
    @optvalue = 'false';

EXEC sp_serveroption
    @server = 'ConnectionInstancia1AdventureWorks',
    @optname = 'sub', -- subscriber
    @optvalue = 'false';

EXEC sp_serveroption
    @server = 'ConnectionInstancia1AdventureWorks',
    @optname = 'Lazy Schema Validation',
    @optvalue = 'false';
GO

--Hacia el segundo fragmento
 EXEC sp_addlinkedserver
   @server=N'ConnectionInstancia2AdventureWorks',
   @srvproduct=N'SQLServer',
   @provider=N'SQLOLEDB', -- Microsoft OLE DB Provider for SQL Server
   @datasrc=N'(Dirección)\(Nombre-Instancia)';

EXEC sp_addlinkedsrvlogin
    @rmtsrvname = N'ConnectionInstancia2AdventureWorks',
    @useself = N'true', -- Se conecta con al servidor remoto con las credenciales actuales del servidor local
    @locallogin = NULL; -- Se establece en NULL para que se vean afectados todos los inicios de sesión locales

EXEC sp_serveroption
    @server = 'ConnectionInstancia2AdventureWorks',
    @optname = 'Collation Compatible',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionInstancia2AdventureWorks',
    @optname = 'Data Access',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionInstancia2AdventureWorks',
    @optname = 'RPC',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionInstancia2AdventureWorks',
    @optname = 'RPC out',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionInstancia2AdventureWorks',
    @optname = 'Use Remote Collation',
    @optvalue = 'true';

EXEC sp_serveroption -- PENDIENTE
    @server = 'ConnectionInstancia2AdventureWorks',
    @optname = 'remote proc transaction promotion',
    -- Enable Promotion of Distributed Transactions for RPC
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionInstancia2AdventureWorks',
    @optname = 'Dist', --Distributor
    @optvalue = 'false';


EXEC sp_serveroption
    @server = 'ConnectionInstancia2AdventureWorks',
    @optname = 'Pub', --publisher
    @optvalue = 'false';

EXEC sp_serveroption
    @server = 'ConnectionInstancia2AdventureWorks',
    @optname = 'sub', -- subscriber
    @optvalue = 'false';

EXEC sp_serveroption
    @server = 'ConnectionInstancia2AdventureWorks',
    @optname = 'Lazy Schema Validation',
    @optvalue = 'false';
GO


--Fragmentación de Person
insert into ConnectionInstancia1AdventureWorks.Fragmento1AW.dbo.Person
 select 
    BusinessEntityID,
    PersonType,
    NameStyle,
    Title,
    FirstName,
    MiddleName,
    LastName,
    Suffix,
    EmailPromotion,
    rowguid,
    ModifiedDate
 from Person.Person where EmailPromotion = 0

 insert into ConnectionInstancia2AdventureWorks.Fragmento2AW.dbo.Person 
 select 
    BusinessEntityID,
    PersonType,
    NameStyle,
    Title,
    FirstName,
    MiddleName,
    LastName,
    Suffix,
    EmailPromotion,
    rowguid,
    ModifiedDate
 from Person.Person where EmailPromotion != 0
 GO

--Copia de la tabla SalesTerritory
insert into ConnectionInstancia1AdventureWorks.Fragmento1AW.dbo.SalesTerritory
([Name], CountryRegionCode,[Group], SalesYTD, SalesLastYear, CostYTD, CostLastYear, rowguid, ModifiedDate)
select [Name], CountryRegionCode,[Group], SalesYTD, SalesLastYear, CostYTD, CostLastYear, rowguid, ModifiedDate
from Sales.SalesTerritory

insert into ConnectionInstancia2AdventureWorks.Fragmento2AW.dbo.SalesTerritory 
([Name], CountryRegionCode,[Group], SalesYTD, SalesLastYear, CostYTD, CostLastYear, rowguid, ModifiedDate)
select [Name], CountryRegionCode,[Group], SalesYTD, SalesLastYear, CostYTD, CostLastYear, rowguid, ModifiedDate
from Sales.SalesTerritory
GO

--Fragmentación de Customer
insert into ConnectionInstancia1AdventureWorks.Fragmento1AW.dbo.Customer 
select Customer.* from Sales.Customer join Person.Person
on customer.PersonID = Person.BusinessEntityID and 
Person.EmailPromotion = 0;

insert into ConnectionInstancia2AdventureWorks.Fragmento2AW.dbo.Customer 
select Customer.* from Sales.Customer join Person.Person
on customer.PersonID = Person.BusinessEntityID and 
Person.EmailPromotion != 0;
GO

--Fragmentación de Employee
insert into ConnectionInstancia1AdventureWorks.Fragmento1AW.dbo.Employee 
 select 
    Employee.BusinessEntityID,
    Employee.NationalIDNumber,
    Employee.LoginID,
    Employee.OrganizationLevel,
    Employee.JobTitle,
    Employee.BirthDate,
    Employee.MaritalStatus,
    Employee.Gender,
    Employee.HireDate,
    Employee.SalariedFlag,
    Employee.VacationHours,
    Employee.SickLeaveHours,
    Employee.CurrentFlag,
    Employee.rowguid,
    Employee.ModifiedDate
 from HumanResources.Employee join Person.Person on 
 Employee.BusinessEntityID = Person.BusinessEntityID and 
 Person.EmailPromotion = 0;

 insert into ConnectionInstancia2AdventureWorks.Fragmento2AW.dbo.Employee 
 select 
    Employee.BusinessEntityID,
    Employee.NationalIDNumber,
    Employee.LoginID,
    Employee.OrganizationLevel,
    Employee.JobTitle,
    Employee.BirthDate,
    Employee.MaritalStatus,
    Employee.Gender,
    Employee.HireDate,
    Employee.SalariedFlag,
    Employee.VacationHours,
    Employee.SickLeaveHours,
    Employee.CurrentFlag,
    Employee.rowguid,
    Employee.ModifiedDate
 from HumanResources.Employee join Person.Person on 
 Employee.BusinessEntityID = Person.BusinessEntityID and 
 Person.EmailPromotion != 0;
 GO

 --Fragmentación de SalesPerson
 insert into ConnectionInstancia1AdventureWorks.Fragmento1AW.dbo.SalesPerson 
 select SalesPerson.* from Sales.SalesPerson join Person.Person
 on SalesPerson.BusinessEntityID  = Person.BusinessEntityID and 
 Person.EmailPromotion = 0;

 insert into ConnectionInstancia2AdventureWorks.Fragmento2AW.dbo.SalesPerson 
 select SalesPerson.* from Sales.SalesPerson join Person.Person
 on SalesPerson.BusinessEntityID  = Person.BusinessEntityID and 
 Person.EmailPromotion != 0;
 GO

 --Fragmentación de Store
 insert into ConnectionInstancia1AdventureWorks.Fragmento1AW.dbo.Store 
 select 
    Store.BusinessEntityID,
    Store.[Name],
    Store.SalesPersonID,
    Store.rowguid,
    Store.ModifiedDate
 from Sales.Store join Person.Person on Person.BusinessEntityID = Store.SalesPersonID
and EmailPromotion = 0

insert into ConnectionInstancia2AdventureWorks.Fragmento2AW.dbo.Store 
 select 
    Store.BusinessEntityID,
    Store.[Name],
    Store.SalesPersonID,
    Store.rowguid,
    Store.ModifiedDate
 from Sales.Store join Person.Person on Person.BusinessEntityID = Store.SalesPersonID
and EmailPromotion != 0
GO

 --Fragmentación de ShipMethod
 insert into ConnectionInstancia1AdventureWorks.Fragmento1AW.dbo.ShipMethod 
 select * from Purchasing.ShipMethod

 insert into ConnectionInstancia2AdventureWorks.Fragmento2AW.dbo.ShipMethod 
 select * from Purchasing.ShipMethod

 --Fragmentación de Sales.SalesReason
 insert into ConnectionInstancia1AdventureWorks.Fragmento1AW.dbo.SalesReason 
 select * from Sales.SalesReason

 insert into ConnectionInstancia2AdventureWorks.Fragmento2AW.dbo.SalesReason 
 select * from Sales.SalesReason

  --Fragmentación de SalesOrderHeader
 insert into ConnectionInstancia1AdventureWorks.Fragmento1AW.dbo.SalesOrderHeader 
 select SalesOrderHeader.*
 from Sales.SalesOrderHeader join Sales.Customer on 
 SalesOrderHeader.CustomerID = Customer.CustomerID 
 join Person.Person on Person.BusinessEntityID = Customer.PersonID
 and Person.EmailPromotion = 0

 insert into ConnectionInstancia2AdventureWorks.Fragmento2AW.dbo.SalesOrderHeader 
 select SalesOrderHeader.*
 from Sales.SalesOrderHeader join Sales.Customer on 
 SalesOrderHeader.CustomerID = Customer.CustomerID 
 join Person.Person on Person.BusinessEntityID = Customer.PersonID
 and Person.EmailPromotion != 0

 --Fragmentación de SalesOrderHeaderSalesReason
  insert into ConnectionInstancia1AdventureWorks.Fragmento1AW.dbo.SalesOrderHeaderSalesReason 
  select SOHSR.* from Sales.SalesOrderHeaderSalesReason SOHSR join Sales.SalesOrderHeader SOH
  on SOHSR.SalesOrderID = SOH.SalesOrderID
 join Sales.Customer on SOH.CustomerID = Customer.CustomerID 
 join Person.Person on Person.BusinessEntityID = Customer.PersonID
 and Person.EmailPromotion = 0

  insert into ConnectionInstancia2AdventureWorks.Fragmento2AW.dbo.SalesOrderHeaderSalesReason 
  select SOHSR.* from Sales.SalesOrderHeaderSalesReason SOHSR join Sales.SalesOrderHeader SOH
  on SOHSR.SalesOrderID = SOH.SalesOrderID
 join Sales.Customer on SOH.CustomerID = Customer.CustomerID 
 join Person.Person on Person.BusinessEntityID = Customer.PersonID
 and Person.EmailPromotion != 0

 /*select COLUMN_NAME
  from INFORMATION_SCHEMA.COLUMNS
 where TABLE_SCHEMA = 'Sales'
   and TABLE_NAME = 'SalesReason'
 order by ORDINAL_POSITION*/