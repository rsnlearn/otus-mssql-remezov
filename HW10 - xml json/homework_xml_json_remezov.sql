/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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

USE WideWorldImporters;

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

-- напишите здесь свое решение
-- OPENXML
DECLARE @StockItemsXmlDoc XML
SELECT @StockItemsXmlDoc = BulkColumn FROM OPENROWSET(BULK N'C:\temp\StockItems.xml', SINGLE_CLOB) xd

DECLARE @hStockItemsXmlDoc INT
EXEC sp_xml_preparedocument @hStockItemsXmlDoc OUTPUT, @StockItemsXmlDoc;

SELECT *
FROM OPENXML(@hStockItemsXmlDoc, N'/StockItems/Item')
WITH (
	StockItemName [nvarchar](100) N'@Name'
	,SupplierID [int] N'SupplierID'
	,UnitPackageID [int] N'Package/UnitPackageID'
	,OuterPackageID [int] N'Package/OuterPackageID'
	,QuantityPerOuter [int] N'Package/QuantityPerOuter'
	,TypicalWeightPerUnit [decimal](18, 3) N'Package/TypicalWeightPerUnit'
	,LeadTimeDays [int] N'LeadTimeDays'
	,IsChillerStock [bit] N'IsChillerStock'
	,TaxRate [decimal](18, 3) N'TaxRate'
	,UnitPrice [decimal](18, 2) N'UnitPrice') 

EXEC sp_xml_removedocument @hStockItemsXmlDoc;

-- XQuery
DECLARE @StockItemsXmlDoc XML
SELECT @StockItemsXmlDoc = BulkColumn FROM OPENROWSET(BULK N'C:\temp\StockItems.xml', SINGLE_CLOB) xd

DROP TABLE IF EXISTS #StockItemsXml
SELECT
	x.value('@Name', '[nvarchar](100)') AS StockItemName
	,x.value('SupplierID[1]', '[int]') AS SupplierID
	,x.value('Package[1]/UnitPackageID[1]', '[int]') AS UnitPackageID
	,x.value('Package[1]/OuterPackageID[1]', '[int]') AS OuterPackageID
	,x.value('Package[1]/QuantityPerOuter[1]', '[int]') AS QuantityPerOuter
	,x.value('Package[1]/TypicalWeightPerUnit[1]', '[decimal](18, 3)') AS TypicalWeightPerUnit
	,x.value('LeadTimeDays[1]', '[int]') AS LeadTimeDays
	,x.value('IsChillerStock[1]', '[bit]') AS IsChillerStock
	,x.value('TaxRate[1]', '[decimal](18, 3)') AS TaxRate
	,x.value('UnitPrice[1]', '[decimal](18, 2)') AS UnitPrice
INTO #StockItemsXml
FROM
	@StockItemsXmlDoc.nodes(N'/StockItems/Item') ItemXml(x)

MERGE Warehouse.StockItems si
USING #StockItemsXml six
ON six.StockItemName = si.StockItemName
WHEN MATCHED
	THEN UPDATE SET
		si.StockItemName = six.StockItemName
		,si.SupplierID = six.SupplierID
		,si.UnitPackageID = six.UnitPackageID
		,si.OuterPackageID = six.OuterPackageID
		,si.QuantityPerOuter = six.QuantityPerOuter
		,si.TypicalWeightPerUnit = six.TypicalWeightPerUnit
		,si.LeadTimeDays = six.LeadTimeDays
		,si.IsChillerStock = six.IsChillerStock
		,si.TaxRate = six.TaxRate
		,si.UnitPrice = six.UnitPrice
		,si.LastEditedBy = 1 /*Data Conversion Only user*/
WHEN NOT MATCHED 
	THEN INSERT (
		StockItemName
		,SupplierID
		,UnitPackageID
		,OuterPackageID
		,QuantityPerOuter
		,TypicalWeightPerUnit
		,LeadTimeDays
		,IsChillerStock
		,TaxRate
		,UnitPrice
		,LastEditedBy)
	VALUES (
		six.StockItemName
		,six.SupplierID
		,six.UnitPackageID
		,six.OuterPackageID
		,six.QuantityPerOuter
		,six.TypicalWeightPerUnit
		,six.LeadTimeDays
		,six.IsChillerStock
		,six.TaxRate
		,six.UnitPrice
		,1 /*Data Conversion Only user*/);

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

-- напишите здесь свое решение
EXEC master.dbo.sp_configure 'show advanced options', 1
RECONFIGURE
EXEC master.dbo.sp_configure 'xp_cmdshell', 1
RECONFIGURE
GO

DECLARE @StockItems2XmlSql NVARCHAR(MAX) = 
	N'USE WideWorldImporters;'
	+ N'SELECT '
	+ N'StockItemName AS [@Name]'
		+ N',SupplierID AS [SupplierID]'
		+ N',UnitPackageID AS [Package/UnitPackageID]'
		+ N',OuterPackageID AS [Package/OuterPackageID]'
		+ N',QuantityPerOuter AS [Package/QuantityPerOuter]'
		+ N',TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit]'
		+ N',LeadTimeDays AS [LeadTimeDays]'
		+ N',IsChillerStock AS [IsChillerStock]'
		+ N',TaxRate AS [TaxRate]'
		+ N',UnitPrice AS [UnitPrice] '
	+ N'FROM Warehouse.StockItems FOR XML PATH(''Item''), ROOT(''StockItems''), TYPE;'

DECLARE @BcpCommand NVARCHAR(4000)= N'bcp "' + @StockItems2XmlSql + N'" queryout "C:\temp\StockItemsOut.xml" -w -T -S ' + @@SERVERNAME
EXEC master..xp_cmdshell @BcpCommand

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

-- напишите здесь свое решение
SELECT
	StockItemID
	,StockItemName
	,JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture
	,JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
FROM Warehouse.StockItems
 
/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

-- напишите здесь свое решение

SELECT
	StockItemID
	,StockItemName
	,STUFF(
		(SELECT ', ' + value
		FROM OPENJSON(si.CustomFields, '$.Tags')
		ORDER BY value
		FOR XML PATH ('')), 1, 2, N'') AS TagsList
FROM Warehouse.StockItems si
CROSS APPLY
	OPENJSON(si.CustomFields, '$.Tags') tags
WHERE tags.value = 'Vintage'
