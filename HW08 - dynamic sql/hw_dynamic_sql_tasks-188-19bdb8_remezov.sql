/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


-- напишите здесь свое решение

-- запрос с количеством купленных товаров по клиентам по месяцам
DECLARE @sql NVARCHAR(MAX) = ''
DECLARE @ColumnNames NVARCHAR(MAX) = NULL
DECLARE @IsNullForSales NVARCHAR(MAX) = NULL

SELECT @ColumnNames = ISNULL(@ColumnNames + N', ',N'') + QUOTENAME(CustomerName)
FROM Sales.Customers
ORDER BY CustomerName

SELECT @IsNullForSales = ISNULL(@IsNullForSales + N', ',N'') + N'ISNULL(' + QUOTENAME(CustomerName) + ',0) AS ' + QUOTENAME(CustomerName)
FROM Sales.Customers
ORDER BY CustomerName

SET @SQL = N'
WITH
cp AS (
	SELECT
		DATEFROMPARTS(YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), 1) AS InvoiceMonth
		,il.Quantity
		,c.CustomerName
	FROM Sales.Invoices i
	INNER JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
	INNER JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
)
SELECT 
	InvoiceMonth AS InvoiceMonth
	,' + @IsNullForSales + '
FROM cp
PIVOT(
	SUM(cp.Quantity)
	FOR CustomerName IN (' + @ColumnNames + ')
) PivotTable
ORDER BY InvoiceMonth'

EXEC sp_executesql @SQL

-- запрос с количеством инвойсов по клиентам по месяцам
DECLARE @sql NVARCHAR(MAX) = ''
DECLARE @ColumnNames NVARCHAR(MAX) = NULL
DECLARE @IsNullForSales NVARCHAR(MAX) = NULL

SELECT @ColumnNames = ISNULL(@ColumnNames + N', ',N'') + QUOTENAME(CustomerName)
FROM Sales.Customers
ORDER BY CustomerName

SELECT @IsNullForSales = ISNULL(@IsNullForSales + N', ',N'') + N'ISNULL(' + QUOTENAME(CustomerName) + ',0) AS ' + QUOTENAME(CustomerName)
FROM Sales.Customers
ORDER BY CustomerName

SET @SQL = N'
WITH
cp AS (
	SELECT
		DATEFROMPARTS(YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), 1) AS InvoiceMonth
		,1 AS Quantity
		,c.CustomerName
	FROM Sales.Invoices i
	INNER JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
)
SELECT 
	InvoiceMonth AS InvoiceMonth
	,' + @IsNullForSales + '
FROM cp
PIVOT(
	COUNT(cp.Quantity)
	FOR CustomerName IN (' + @ColumnNames + ')
) PivotTable
ORDER BY InvoiceMonth'

EXEC sp_executesql @SQL