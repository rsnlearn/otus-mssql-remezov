/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

--напишите здесь свое решение
;WITH
tc AS(
	(SELECT CustomerID, SUBSTRING(CustomerName, 16, LEN(CustomerName) - 16) AS TailspinCity
	FROM Sales.Customers
	WHERE CustomerID BETWEEN 2 AND 6)
)
,cp AS (
	SELECT
		DATEFROMPARTS(YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), 1) AS InvoiceMonth
		,il.Quantity
		,TailspinCity
	FROM Sales.Invoices i
	INNER JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
	INNER JOIN tc on tc.CustomerID = i.CustomerID
)
SELECT 
	InvoiceMonth AS InvoiceMonth
	,ISNULL([Gasport, NY], 0) AS [Gasport, NY]
	,ISNULL([Jessie, ND], 0) AS [Jessie, ND]
	,ISNULL([Medicine Lodge, KS], 0) AS [Medicine Lodge, KS]
	,ISNULL([Peeples Valley, AZ], 0) AS [Peeples Valley, AZ]
	,ISNULL([Sylvanite, MT], 0) AS [Sylvanite, MT]
FROM cp
PIVOT(
	SUM(cp.Quantity)
	FOR TailspinCity IN ([Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT])
) PivotTable
ORDER BY InvoiceMonth

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

--напишите здесь свое решение
SELECT
	CustomerName
	,AddressLine
FROM (
	SELECT
		CustomerName
		,[DeliveryAddressLine1]
		,[DeliveryAddressLine2]
		,[PostalAddressLine1]
		,[PostalAddressLine2]
	FROM Sales.Customers
	WHERE CustomerName LIKE '%Tailspin Toys%') pvt
	UNPIVOT (AddressLine FOR Line IN([DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2])) upvt


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

--напишите здесь свое решение
SELECT
	CountryId
	,CountryName
	,Code
FROM (
	SELECT
		CountryId
		,CountryName
		,[IsoAlpha3Code] 
		,CAST([IsoNumericCode] AS NVARCHAR(3)) AS [IsoNumericCodeChar]
	FROM Application.Countries) pvt
	UNPIVOT (Code FOR IsoCode IN([IsoAlpha3Code], [IsoNumericCodeChar])) upvt

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

--напишите здесь свое решение
SELECT
	c.CustomerID
	,c.CustomerName
	,ctp.StockItemID
	,ctp.UnitPrice
	,ctp.InvoiceDate
FROM
	Sales.Customers c
CROSS APPLY (
	SELECT TOP 2
		si.StockItemID
		,si.UnitPrice
		,(SELECT MAX(InvoiceDate)
		 FROM Sales.Invoices i 
		 INNER JOIN Sales.InvoiceLines il
		 ON il.InvoiceID = i.InvoiceID 
		 WHERE il.StockItemID = si.StockItemID 
			AND c.CustomerID = i.CustomerID) AS InvoiceDate
	FROM
		Warehouse.StockItems si
	WHERE
		(SELECT COUNT(*)
		FROM Sales.Invoices i
		INNER JOIN Sales.InvoiceLines il
		ON il.InvoiceID = i.InvoiceID
		WHERE il.StockItemID = si.StockItemID
			AND c.CustomerID = i.CustomerID) > 0
	ORDER BY
		si.UnitPrice DESC) ctp
ORDER BY
	c.CustomerID
	,c.CustomerName
	,ctp.UnitPrice DESC
	,ctp.InvoiceDate DESC
