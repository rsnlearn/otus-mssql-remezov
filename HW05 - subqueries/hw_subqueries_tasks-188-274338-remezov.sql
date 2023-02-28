/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

--TODO: напишите здесь свое решение
--  1) через вложенный запрос
SELECT
	p.PersonID
	,p.FullName
FROM
	[Application].People p
WHERE
	p.IsSalesperson = 1
	AND (SELECT COUNT(*) FROM Sales.Invoices WHERE InvoiceDate = '20150704' AND SalespersonPersonID = p.PersonID) = 0
ORDER BY FullName

--  2) через WITH (для производных таблиц)
;WITH
	SalesPersons AS (
		SELECT 
			PersonID
			,FullName
		FROM
			[Application].People
		WHERE
			IsSalesperson = 1)
	,DaySales AS (
		SELECT
			COUNT(*) AS InvoicesCount
			,SalespersonPersonID
		FROM Sales.Invoices
		WHERE InvoiceDate = '20150704'
		GROUP BY (SalespersonPersonID)
		HAVING COUNT(*)  > 0)
SELECT
	PersonID
	,FullName
FROM
	SalesPersons
LEFT JOIN
	DaySales
	ON DaySales.SalespersonPersonID = SalesPersons.PersonID
WHERE
	DaySales.InvoicesCount IS NULL
ORDER BY SalesPersons.FullName

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

--TODO: напишите здесь свое решение
--  1) через вложенный запрос
--  вложенный запрос 1
SELECT
	StockItemID
	,StockItemName
	,UnitPrice
FROM
	Warehouse.StockItems
WHERE
	UnitPrice = (SELECT MIN(UnitPrice) FROM Warehouse.StockItems)

-- вариант с ALL (медленнее, чем с MIN 69% против 31% и Table 'StockItems'. Scan count 2, logical reads 32 против Table 'StockItems'. Scan count 1, logical reads 1)
SELECT
	StockItemID
	,StockItemName
	,UnitPrice
FROM
	Warehouse.StockItems
WHERE
	UnitPrice <= ALL (SELECT UnitPrice FROM Warehouse.StockItems)

--  вложенный запрос 2
SELECT
	StockItemID
	,StockItemName
	,UnitPrice
FROM (
	SELECT
		StockItemID
		,StockItemName
		,UnitPrice
		,RANK() OVER (ORDER BY UnitPrice) AS UnitPriceRank
	FROM
		Warehouse.StockItems) siupr
WHERE
	UnitPriceRank = 1

--  2) через WITH (для производных таблиц)
;WITH
	siupr AS (
		SELECT
			StockItemID
			,StockItemName
			,UnitPrice
			,RANK() OVER (ORDER BY UnitPrice) AS UnitPriceRank
		FROM
			Warehouse.StockItems
		)
SELECT
	StockItemID
	,StockItemName
	,UnitPrice
FROM siupr
WHERE
	UnitPriceRank = 1

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

--TODO: напишите здесь свое решение
-- через оконные функции
SELECT DISTINCT
	CustomerID
	,CustomerName
FROM
	(SELECT
		ct.CustomerID
		,c.CustomerName
		,ROW_NUMBER() OVER (ORDER BY ct.TransactionAmount DESC) AS TransactionRowRank
	FROM 
		Sales.CustomerTransactions ct
	INNER JOIN
		Sales.Customers c
		ON c.CustomerID = ct.CustomerID) ctr
WHERE 
	TransactionRowRank <= 5

--  1) через вложенный запрос
SELECT DISTINCT
	t5tc.CustomerID
	,c.CustomerName
FROM (
	SELECT TOP 5
		ct.CustomerID
	FROM
		Sales.CustomerTransactions ct
	ORDER BY
		ct.TransactionAmount DESC) t5tc
INNER JOIN
	Sales.Customers c
	ON c.CustomerID = t5tc.CustomerID
	
--  2) через WITH (для производных таблиц)
;WITH
	t5tc AS(
		SELECT TOP 5
		ct.CustomerID
	FROM
		Sales.CustomerTransactions ct
	ORDER BY
		ct.TransactionAmount DESC)
SELECT DISTINCT
	t5tc.CustomerID
	,c.CustomerName
FROM
	t5tc
LEFT JOIN
	Sales.Customers c
	ON c.CustomerID = t5tc.CustomerID

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

--TODO: напишите здесь свое решение
--  1) через вложенный запрос
SELECT DISTINCT
	cu.DeliveryCityID
	,ci.CityName AS DeliveryCityName
	,p.FullName AS PackedByPersonName
FROM
	Sales.Invoices i
INNER JOIN
	Sales.InvoiceLines il
	ON il.InvoiceID = i.InvoiceID
INNER JOIN
	(SELECT TOP 3
		StockItemID
	FROM
		Warehouse.StockItems
	ORDER BY
		UnitPrice DESC) t3si
	ON t3si.StockItemID = il.StockItemID
INNER JOIN
	Sales.Customers cu
	ON cu.CustomerID = i.CustomerID
INNER JOIN
	[Application].Cities ci
	ON ci.CityID = cu.DeliveryCityID
INNER JOIN
	[Application].People p
	ON p.PersonID = i.PackedByPersonID

--  2) через WITH (для производных таблиц)
;WITH
	t3si AS(
		SELECT TOP 3
		StockItemID
	FROM
		Warehouse.StockItems
	ORDER BY
		UnitPrice DESC)
SELECT DISTINCT
	cu.DeliveryCityID
	,ci.CityName AS DeliveryCityName
	,p.FullName AS PackedByPersonName
FROM
	Sales.Invoices i
INNER JOIN
	Sales.InvoiceLines il
	ON il.InvoiceID = i.InvoiceID
INNER JOIN
	t3si
	ON t3si.StockItemID = il.StockItemID
INNER JOIN
	Sales.Customers cu
	ON cu.CustomerID = i.CustomerID
INNER JOIN
	[Application].Cities ci
	ON ci.CityID = cu.DeliveryCityID
INNER JOIN
	[Application].People p
	ON p.PersonID = i.PackedByPersonID

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

--TODO: напишите здесь свое решение
-- Запрос выводит список инвойсов с общей суммой > 27000
-- Список содержит: Ид инвойса, Дату инвойса, Имя ответственного сотрудника, Сумму инвойса,  Сумму по полностью отгруженным заказам
-- Список упорядочен по сумме инвойса по убыванию

--Вариант на JOIN
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	OrdersTotal.PickedSumm AS TotalSummForPickedItems
FROM 
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
INNER JOIN
	Sales.Invoices
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
INNER JOIN
	[Application].People
		ON People.PersonID = Invoices.SalespersonPersonID
LEFT JOIN
	(SELECT OrderLines.OrderId, SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice) AS PickedSumm
	FROM Sales.OrderLines
	INNER JOIN
		Sales.Orders
		ON OrderLines.OrderId = Orders.OrderId
	WHERE Orders.PickingCompletedWhen IS NOT NULL
	GROUP BY OrderLines.OrderId) OrdersTotal
		ON OrdersTotal.OrderId = Invoices.OrderId
ORDER BY TotalSummByInvoice DESC

-- производительность не изменилась, основные затраты на чтение из таблицы Invoices (Table 'Invoices'. Scan count 3, logical reads 11994)
-- количество чтений совпадает