/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

DELETE FROM SALES.Customers WHERE CustomerName Like '%Division%'
/*
1.  в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

--напишите здесь свое решение
INSERT INTO Sales.Customers (
    [CustomerName]
    ,[BillToCustomerID]
    ,[CustomerCategoryID]
    ,[BuyingGroupID]
    ,[PrimaryContactPersonID]
    ,[AlternateContactPersonID]
    ,[DeliveryMethodID]
    ,[DeliveryCityID]
    ,[PostalCityID]
    ,[CreditLimit]
    ,[AccountOpenedDate]
    ,[StandardDiscountPercentage]
    ,[IsStatementSent]
    ,[IsOnCreditHold]
    ,[PaymentDays]
    ,[PhoneNumber]
    ,[FaxNumber]
    ,[DeliveryRun]
    ,[RunPosition]
    ,[WebsiteURL]
    ,[DeliveryAddressLine1]
    ,[DeliveryAddressLine2]
    ,[DeliveryPostalCode]
    ,[DeliveryLocation]
    ,[PostalAddressLine1]
    ,[PostalAddressLine2]
    ,[PostalPostalCode]
    ,[LastEditedBy])
SELECT
	'Tailspin Toys(Head Office, Division' + FORMAT(b.BranchNum, '00') + ')' AS [CustomerName]
    ,c.[BillToCustomerID]
    ,c.[CustomerCategoryID]
    ,c.[BuyingGroupID]
    ,c.[PrimaryContactPersonID]
    ,c.[AlternateContactPersonID]
    ,c.[DeliveryMethodID]
    ,c.[DeliveryCityID]
    ,c.[PostalCityID]
    ,c.[CreditLimit]
    ,c.[AccountOpenedDate]
    ,c.[StandardDiscountPercentage]
    ,c.[IsStatementSent]
    ,c.[IsOnCreditHold]
    ,c.[PaymentDays]
    ,c.[PhoneNumber]
    ,c.[FaxNumber]
    ,c.[DeliveryRun]
    ,c.[RunPosition]
    ,c.[WebsiteURL]
    ,c.[DeliveryAddressLine1]
    ,c.[DeliveryAddressLine2]
    ,c.[DeliveryPostalCode]
    ,c.[DeliveryLocation]
    ,c.[PostalAddressLine1]
    ,c.[PostalAddressLine2]
    ,c.[PostalPostalCode]
    ,c.[LastEditedBy]
FROM (
	SELECT
		 [BillToCustomerID]
		,[CustomerCategoryID]
		,[BuyingGroupID]
		,[PrimaryContactPersonID]
		,[AlternateContactPersonID]
		,[DeliveryMethodID]
		,[DeliveryCityID]
		,[PostalCityID]
		,[CreditLimit]
		,[AccountOpenedDate]
		,[StandardDiscountPercentage]
		,[IsStatementSent]
		,[IsOnCreditHold]
		,[PaymentDays]
		,[PhoneNumber]
		,[FaxNumber]
		,[DeliveryRun]
		,[RunPosition]
		,[WebsiteURL]
		,[DeliveryAddressLine1]
		,[DeliveryAddressLine2]
		,[DeliveryPostalCode]
		,[DeliveryLocation]
		,[PostalAddressLine1]
		,[PostalAddressLine2]
		,[PostalPostalCode]
		,[LastEditedBy]
	FROM
		Sales.Customers
	WHERE CustomerID =1) c
CROSS APPLY
	(VALUES (1), (2), (3), (4), (5)) AS b(BranchNum);

-- запрос для проверки
SELECT * FROM Sales.Customers
WHERE CustomerName Like '%Division%'

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

--напишите здесь свое решение
DELETE
FROM Sales.Customers
WHERE CustomerName Like '%Division04%'

-- запрос для проверки
SELECT * FROM Sales.Customers
WHERE CustomerName Like '%Division%'

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

--напишите здесь свое решение
UPDATE Sales.Customers
SET CustomerName = REPLACE(CustomerName, 'Division05', 'Division04')
WHERE CustomerName Like '%Division05%'

-- запрос для проверки
SELECT * FROM Sales.Customers
WHERE CustomerName Like '%Division%'

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

--напишите здесь свое решение
MERGE Sales.Customers t
USING (
	SELECT
		'Tailspin Toys(Head Office, Division05)' AS [CustomerName]
		,[BillToCustomerID]
		,[CustomerCategoryID]
		,[BuyingGroupID]
		,[PrimaryContactPersonID]
		,[AlternateContactPersonID]
		,[DeliveryMethodID]
		,[DeliveryCityID]
		,[PostalCityID]
		,[CreditLimit]
		,[AccountOpenedDate]
		,[StandardDiscountPercentage]
		,[IsStatementSent]
		,[IsOnCreditHold]
		,[PaymentDays]
		,[PhoneNumber]
		,[FaxNumber]
		,[DeliveryRun]
		,[RunPosition]
		,[WebsiteURL]
		,[DeliveryAddressLine1]
		,[DeliveryAddressLine2]
		,[DeliveryPostalCode]
		,[DeliveryLocation]
		,[PostalAddressLine1]
		,[PostalAddressLine2]
		,[PostalPostalCode]
		,[LastEditedBy]
	FROM Sales.Customers
	WHERE CustomerID =1) s
ON (s.CustomerName = t.CustomerName)
WHEN MATCHED
	THEN UPDATE SET
		 [CustomerName] = s.[CustomerName]
		,[BillToCustomerID] = s.[BillToCustomerID]
		,[CustomerCategoryID] = s.[CustomerCategoryID]
		,[BuyingGroupID] = s.[BuyingGroupID]
		,[PrimaryContactPersonID] = s.[PrimaryContactPersonID]
		,[AlternateContactPersonID] = s.[AlternateContactPersonID]
		,[DeliveryMethodID] = s.[DeliveryMethodID]
		,[DeliveryCityID] = s.[DeliveryCityID]
		,[PostalCityID] = s.[PostalCityID]
		,[CreditLimit] = s.[CreditLimit]
		,[AccountOpenedDate] = s.[AccountOpenedDate]
		,[StandardDiscountPercentage] = s.[StandardDiscountPercentage]
		,[IsStatementSent] = s.[IsStatementSent]
		,[IsOnCreditHold] = s.[IsOnCreditHold]
		,[PaymentDays] = s.[PaymentDays]
		,[PhoneNumber] = s.[PhoneNumber]
		,[FaxNumber] = s.[FaxNumber]
		,[DeliveryRun] = s.[DeliveryRun]
		,[RunPosition] = s.[RunPosition]
		,[WebsiteURL] = s.[WebsiteURL]
		,[DeliveryAddressLine1] = s.[DeliveryAddressLine1]
		,[DeliveryAddressLine2] = s.[DeliveryAddressLine2]
		,[DeliveryPostalCode] = s.[DeliveryPostalCode]
		,[DeliveryLocation] = s.[DeliveryLocation]
		,[PostalAddressLine1] = s.[PostalAddressLine1]
		,[PostalAddressLine2] = s.[PostalAddressLine2]
		,[PostalPostalCode] = s.[PostalPostalCode]
		,[LastEditedBy] = s.[LastEditedBy]
WHEN NOT MATCHED 
	THEN INSERT (
		[CustomerName]
		,[BillToCustomerID]
		,[CustomerCategoryID]
		,[BuyingGroupID]
		,[PrimaryContactPersonID]
		,[AlternateContactPersonID]
		,[DeliveryMethodID]
		,[DeliveryCityID]
		,[PostalCityID]
		,[CreditLimit]
		,[AccountOpenedDate]
		,[StandardDiscountPercentage]
		,[IsStatementSent]
		,[IsOnCreditHold]
		,[PaymentDays]
		,[PhoneNumber]
		,[FaxNumber]
		,[DeliveryRun]
		,[RunPosition]
		,[WebsiteURL]
		,[DeliveryAddressLine1]
		,[DeliveryAddressLine2]
		,[DeliveryPostalCode]
		,[DeliveryLocation]
		,[PostalAddressLine1]
		,[PostalAddressLine2]
		,[PostalPostalCode]
		,[LastEditedBy])
	VALUES (
		s.[CustomerName]
		,s.[BillToCustomerID]
		,s.[CustomerCategoryID]
		,s.[BuyingGroupID]
		,s.[PrimaryContactPersonID]
		,s.[AlternateContactPersonID]
		,s.[DeliveryMethodID]
		,s.[DeliveryCityID]
		,s.[PostalCityID]
		,s.[CreditLimit]
		,s.[AccountOpenedDate]
		,s.[StandardDiscountPercentage]
		,s.[IsStatementSent]
		,s.[IsOnCreditHold]
		,s.[PaymentDays]
		,s.[PhoneNumber]
		,s.[FaxNumber]
		,s.[DeliveryRun]
		,s.[RunPosition]
		,s.[WebsiteURL]
		,s.[DeliveryAddressLine1]
		,s.[DeliveryAddressLine2]
		,s.[DeliveryPostalCode]
		,s.[DeliveryLocation]
		,s.[PostalAddressLine1]
		,s.[PostalAddressLine2]
		,s.[PostalPostalCode]
		,s.[LastEditedBy])
OUTPUT deleted.*, $action, inserted.*;

-- запрос для проверки
SELECT * FROM Sales.Customers
WHERE CustomerName Like '%Division%'
/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

--напишите здесь свое решение

EXEC sp_configure 'show advanced options', 1;  
GO    
RECONFIGURE;  
GO  
EXEC sp_configure 'xp_cmdshell', 1;  
GO   
RECONFIGURE;  
GO

--bcp
DECLARE @var_bcp_command NVARCHAR(4000)= 'bcp "WideWorldImporters.Sales.Customers" out "C:\temp\Customers1.csv" -T -w -t"@eu&$1&" -S ' + @@SERVERNAME
EXEC master..xp_cmdshell @var_bcp_command

--BULK INSERT
DROP TABLE IF EXISTS [Sales].[Customers_BULK]

CREATE TABLE [Sales].[Customers_BULK](
	[CustomerID] [int] NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[CustomerCategoryID] [int] NOT NULL,
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[CreditLimit] [decimal](18, 2) NULL,
	[AccountOpenedDate] [date] NOT NULL,
	[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
	[IsStatementSent] [bit] NOT NULL,
	[IsOnCreditHold] [bit] NOT NULL,
	[PaymentDays] [int] NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](10) NOT NULL,
	[DeliveryLocation] [geography] NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [nvarchar](10) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL,
) ON [USERDATA] TEXTIMAGE_ON [USERDATA]
GO

BULK INSERT [WideWorldImporters].[Sales].[Customers_BULK]
FROM "C:\temp\Customers1.csv"
WITH (
	BATCHSIZE = 4000, 
	DATAFILETYPE = 'widechar',
	FIELDTERMINATOR =  '@eu&$1&',
	ROWTERMINATOR ='\n',
	KEEPNULLS,
	TABLOCK);

SELECT * FROM [Sales].[Customers_BULK]