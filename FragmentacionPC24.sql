--------------------------------FRAGMENTO 2 (EmailPromotion <> 0)
create database Fragmento2AW;
go

use Fragmento2AW;
go

-- CREACIÓN DE TABLAS
create table Person(
	BusinessEntityID int,
	PersonType nchar(2),
	NameStyle bit,
	Title nvarchar(8),
	FirstName nvarchar(50),
	MiddleName nvarchar(50),
	LastName nvarchar(50),
	Suffix nvarchar(10),
	EmailPromotion int,
	rowguid uniqueidentifier,
	ModifiedDate datetime,
	constraint PK_Person_BusinessEntityID primary key (BusinessEntityID)
);
GO

create table SalesTerritory(
	TerritoryID int identity(1,1),
	[Name] nvarchar(50),
	CountryRegionCode nvarchar(3), 
	[Group] nvarchar(50),
	SalesYTD money,
	SalesLastYear money,
	CostYTD money,
	CostLastYear money,
	rowguid uniqueidentifier,
	ModifiedDate datetime
	constraint PK_SalesTerritory_TerritoryID primary key (TerritoryID)
);
GO

create table Customer(
	CustomerID int,
	PersonID int,
	StoreID int,
	TerritoryID int,
	AccountNumber varchar(10),
	rowguid uniqueidentifier,
	ModifiedDate datetime
	constraint PK_Customer_CustomerID primary key (CustomerID)
	CONSTRAINT FK_Customer_Person_PersonID
	FOREIGN KEY (PersonID)
	REFERENCES dbo.Person(BusinessEntityID),
	CONSTRAINT FK_Customer_SalesTerritory_TerritoryID
	FOREIGN KEY (TerritoryID)
	REFERENCES dbo.SalesTerritory(TerritoryID)
);
GO

create table Employee(
	BusinessEntityID int,
	NationalIDNumber nvarchar(15),
	LoginID nvarchar(256),
	OrganizationLevel smallint,
	JobTitle nvarchar(50),
	BirthDate date,
	MaritalStatus nchar(1),
	Gender nchar(15),
	HireDate date,
	SalariedFlag bit,
	VacationHours smallint,
	SickLeaveHours smallint,
	CurrentFlag bit,
	rowguid uniqueidentifier,
	ModifiedDate datetime,
	constraint PK_Employee_BusinessEntityID primary key (BusinessEntityID),
	CONSTRAINT FK_Employee_Person_BusinessEntityID
	FOREIGN KEY (BusinessEntityID)
	REFERENCES dbo.Person(BusinessEntityID)
);
GO

create table SalesPerson(
	BusinessEntityID int,
	TerritoryID int,
	SalesQuota money,
	Bonus money,
	CommissionPct smallmoney,
	SalesYTD money,
	SalesLastYear money,
	rowguid uniqueidentifier,
	ModifiedDate datetime
	constraint PK_SalesPerson_BusinessEntityID primary key (BusinessEntityID),
	CONSTRAINT FK_SalesPerson_Employee_BusinessEntityID
	FOREIGN KEY (BusinessEntityID)
	REFERENCES Employee(BusinessEntityID),
	CONSTRAINT FK_SalesPerson_SalesTerritory_TerritoryID
	FOREIGN KEY (TerritoryID)
	REFERENCES SalesTerritory(TerritoryID)
);
GO

create table Store(
	BusinessEntityID int,
	[Name] nvarchar(50),
	SalesPersonID int,
	rowguid uniqueidentifier,
	ModifiedDate datetime,
	constraint PK_Store_BusinessEntityID primary key (BusinessEntityID),
	CONSTRAINT FK_Store_SalesPerson_SalesPersonID
	FOREIGN KEY (SalesPersonID) 
	REFERENCES SalesPerson(BusinessEntityID),
);
GO

create table ShipMethod(
	ShipMethodID int,
	[Name] nvarchar(50),
	ShipBase money,
	ShipRate money,
	rowguid uniqueidentifier,
	ModifiedDate datetime
	constraint PK_ShipMethod_ShipMethodID primary key (ShipMethodID)
)
GO

create table SalesOrderHeader(
    SalesOrderID int,
    RevisionNumber tinyint,
    OrderDate datetime,
    DueDate datetime,
    ShipDate datetime,
    [Status] tinyint,
    OnlineOrderFlag bit,
    SalesOrderNumber nvarchar(25),
    PurchaseOrderNumber nvarchar(25),
    AccountNumber nvarchar(25),
    CustomerID int,
    SalesPersonID int,
    TerritoryID int,
    BillToAddressID int,
    ShipToAddressID int,
    ShipMethodID int,
    CreditCardID int,
    CreditCardApprovalCode varchar(15), 
    CurrencyRateID int,
    SubTotal money,
    TaxAmt money,
    Freight money,
    TotalDue money,
    Comment nvarchar(128),
    rowguid uniqueidentifier,
    ModifiedDate datetime,
    constraint PK_SalesOrderHeader_SalesOrderID primary key (SalesOrderID),
	CONSTRAINT FK_SalesOrderHeader_Customer_CustomerID
	FOREIGN KEY (CustomerID)
	REFERENCES dbo.Customer(CustomerID),
	CONSTRAINT FK_SalesOrderHeader_SalesTerritory_TerritoryID
	FOREIGN KEY (TerritoryID)
	REFERENCES SalesTerritory(TerritoryID),
	CONSTRAINT FK_SalesOrderHeader_ShipMethod_ShipMethodID
	FOREIGN KEY (ShipMethodID)
	REFERENCES ShipMethod(ShipMethodID)
);
GO

create table SalesReason(
	SalesReasonID int,
	[Name] nvarchar(50),
	ReasonType nvarchar(50),
	ModifiedDate datetime
	constraint PK_SalesReason_SalesReasonID primary key (SalesReasonID)
)
GO

create table SalesOrderHeaderSalesReason(
	SalesOrderID int, 
	SalesReasonID int,
	ModifiedDate datetime,
	constraint PK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID primary key (SalesOrderID, SalesReasonID),
	CONSTRAINT FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID
	FOREIGN KEY (SalesOrderID)
	REFERENCES SalesOrderHeader(SalesOrderID) on delete cascade,
	CONSTRAINT FK_SalesOrderHeaderSalesReason_SalesReason_SalesReasonID
	FOREIGN KEY (SalesReasonID)
	REFERENCES SalesReason(SalesReasonID)
)
GO

--CREACIÓN DE SERVIDOR VINCULADO QUE CONECTARÁ CON EL PRIMER FRAGMENTO
EXEC sp_addlinkedserver
   @server=N'ConnectionFragmeto2a1',
   @srvproduct=N'SQLServer',
   @provider=N'SQLOLEDB', -- Microsoft OLE DB Provider for SQL Server
   @datasrc=N'192.168.229.23';


EXEC sp_addlinkedsrvlogin
    @rmtsrvname = N'ConnectionFragmeto2a1',
    @useself = N'true', -- Se conecta con al servidor remoto con las credenciales actuales del servidor local
    @locallogin = NULL; -- Se establece en NULL para que se vean afectados todos los inicios de sesión locales

EXEC sp_serveroption
    @server = 'ConnectionFragmeto2a1',
    @optname = 'Collation Compatible',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionFragmeto2a1',
    @optname = 'Data Access',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionFragmeto2a1',
    @optname = 'RPC',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionFragmeto2a1',
    @optname = 'RPC out',
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionFragmeto2a1',
    @optname = 'Use Remote Collation',
    @optvalue = 'true';

EXEC sp_serveroption 
    @server = 'ConnectionFragmeto2a1',
    @optname = 'remote proc transaction promotion',
    -- Enable Promotion of Distributed Transactions for RPC
    @optvalue = 'true';

EXEC sp_serveroption
    @server = 'ConnectionFragmeto2a1',
    @optname = 'Dist', --Distributor
    @optvalue = 'false';


EXEC sp_serveroption
    @server = 'ConnectionFragmeto2a1',
    @optname = 'Pub', --publisher
    @optvalue = 'false';

EXEC sp_serveroption
    @server = 'ConnectionFragmeto2a1',
    @optname = 'sub', -- subscriber
    @optvalue = 'false';

EXEC sp_serveroption
    @server = 'ConnectionFragmeto2a1',
    @optname = 'Lazy Schema Validation',
    @optvalue = 'false';
GO


-- CONSULTA QUE DEVUELVE LOS ATRIBUTOS DE UNA TABLA
 /*select COLUMN_NAME
  from INFORMATION_SCHEMA.COLUMNS
 where TABLE_SCHEMA = 'Sales'
   and TABLE_NAME = 'SalesPerson'
 order by ORDINAL_POSITION*/


-- DICCIONARIO DE DISTRIBUCIÓN
CREATE TABLE diccionario_distribucion (
  id_fragmento tinyint primary key, -- identificador del fragmento
  servidor varchar(100), -- nombre del servidor vinculado
  bd varchar(100), -- nombre de la base que aloja al fragmento
  ntabla varchar(100), -- nombre de la tabla que representa fragmento
  col_frag varchar(100) -- columna que se utiliza como criterio de fragmentación
)
GO

-- Tuplas del diccionario
insert into diccionario_distribucion values (1,'ConnectionFragmeto2a1','Fragmento1AW','Person','EmailPromotion');  -- Instancia 1 SQL Server
insert into diccionario_distribucion values (3,'ConnectionFragmeto10a20','Fragmento2AW','Person','EmailPromotion'); -- Instancia 2 SQL Server
GO

 -- Tabla de valores que toma el atributo que se consideró para la fragmentación
CREATE TABLE val_email_promotion (
  id_fragmento tinyint,
  val_col varchar(100),
  primary key (id_fragmento, val_col),
  foreign KEY (id_fragmento) REFERENCES diccionario_distribucion  (id_fragmento)
)
GO

insert into val_email_promotion values (3,'1')
insert into val_email_promotion values (3,'2')